package com.livelook.app.decart

import ai.decart.sdk.ConnectionState
import ai.decart.sdk.DecartClient
import ai.decart.sdk.DecartClientConfig
import ai.decart.sdk.RealtimeModel
import ai.decart.sdk.RealtimeModels
import ai.decart.sdk.realtime.ConnectOptions
import ai.decart.sdk.realtime.InitialPrompt
import ai.decart.sdk.realtime.MirrorMode
import ai.decart.sdk.realtime.RealtimeMediaStream
import android.content.Context
import android.util.Base64
import io.livekit.android.room.Room
import io.livekit.android.room.track.VideoTrack
import java.lang.ref.WeakReference
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/** Which feed a video view is showing. Mirrors the Swift enum. */
enum class DecartVideoSource(val wire: String) {
    /** The phone's own camera, before or alongside a session. */
    LOCAL("local"),

    /** Decart's transformed feed. Only carries a track while connected. */
    REMOTE("remote"),

    /**
     * Whichever feed is current — remote once a session produces one, the
     * camera otherwise. One view instead of two means one renderer running.
     */
    AUTO("auto");

    companion object {
        fun fromWire(value: String?): DecartVideoSource =
            entries.firstOrNull { it.wire == value } ?: AUTO
    }
}

/**
 * Owns the Decart realtime session for the whole app.
 *
 * The SDK owns the camera: [RealTimeClient.createLocalVideoStream] builds the
 * capture track and the session publishes that same track, so nothing else may
 * open the camera at the same time.
 *
 * Everything here runs on the main dispatcher — the LiveKit renderer and the
 * views it feeds are main-thread only.
 */
object DecartSessionBridge {
    private val scope = CoroutineScope(Dispatchers.Main.immediate + SupervisorJob())

    private var client: DecartClient? = null
    private var model: RealtimeModel? = null

    private var localStream: RealtimeMediaStream? = null
    private var remoteStream: RealtimeMediaStream? = null

    private var appContext: Context? = null

    private var stateJob: Job? = null
    private var errorJob: Job? = null
    private var remoteJob: Job? = null
    private var autoDisconnectJob: Job? = null

    /** Views waiting for a track. Weak so a disposed view frees its renderer. */
    private val views = mutableListOf<WeakReference<DecartVideoPlatformView>>()

    /** Emits `(state, message)` for the Dart event channel. */
    var onEvent: ((String, String?) -> Unit)? = null

    // ── Setup ────────────────────────────────────────────────────────────

    /** Builds the client and starts the camera. Repeat calls are no-ops. */
    fun initialize(
        context: Context,
        apiKey: String,
        httpBaseUrl: String,
        wsBaseUrl: String,
        modelName: String,
    ) {
        if (client != null) return

        val resolved = RealtimeModels.fromName(modelName)
            ?: throw IllegalArgumentException("Unknown Decart model: $modelName")

        val ctx = context.applicationContext
        appContext = ctx
        model = resolved
        client = DecartClient(
            ctx,
            DecartClientConfig(
                apiKey = apiKey,
                baseUrl = wsBaseUrl,
                httpBaseUrl = httpBaseUrl,
            ),
        )

        startLocalCamera()
        rebindViews()
        emit("idle")
    }

    // ── Session ──────────────────────────────────────────────────────────

    /** Connects and applies the first garment. */
    suspend fun connect(prompt: String, image: ByteArray?, autoDisconnectSeconds: Double) {
        val active = client ?: throw IllegalStateException(
            "initialize() must run before connect()"
        )
        val chosen = model ?: throw IllegalStateException("no model resolved")
        if (isConnected) return

        emit("connecting")

        val stream = localStream ?: run {
            startLocalCamera()
            localStream
        } ?: throw IllegalStateException("camera unavailable")

        observe()

        try {
            remoteStream = active.realtime.connect(
                options = ConnectOptions(
                    model = chosen,
                    initialPrompt = InitialPrompt(text = prompt, enhance = false),
                    initialImage = image?.toBase64(),
                    mirror = MirrorMode.AUTO,
                ),
                localStream = stream,
            )
            rebindViews()
            scheduleAutoDisconnect(autoDisconnectSeconds)
        } catch (e: Throwable) {
            cancelObservation()
            // Publishing may have started before the failure, which stops the
            // capture track and would strand the preview on a frozen frame.
            restartLocalCamera()
            rebindViews()
            emit("error", e.message ?: "Could not start the try-on session")
            throw e
        }
    }

    /** Swaps the garment on a live session. */
    suspend fun setGarment(prompt: String, image: ByteArray?) {
        val active = client ?: throw IllegalStateException("no active session")
        active.realtime.setImage(
            imageBase64 = image?.toBase64(),
            prompt = prompt,
            enhance = false,
        )
    }

    suspend fun disconnect() {
        autoDisconnectJob?.cancel()
        autoDisconnectJob = null

        client?.realtime?.disconnect()
        remoteStream = null
        cancelObservation()

        restartLocalCamera()
        rebindViews()
        emit("disconnected")
    }

    private val isConnected: Boolean
        get() = client?.realtime?.isConnected() == true

    // ── Camera ───────────────────────────────────────────────────────────

    private fun startLocalCamera() {
        val ctx = appContext ?: return
        val chosen = model ?: return
        localStream = ai.decart.sdk.realtime.RealTimeClient.createLocalVideoStream(
            context = ctx,
            model = chosen,
            mirror = MirrorMode.AUTO,
        )
    }

    /**
     * Rebuilds the capture track after a session ends.
     *
     * The local track is published into the LiveKit room, and closing the room
     * stops it. The stream object survives, so the preview keeps rendering its
     * last frame and looks frozen — only a fresh capture track brings the
     * camera back.
     */
    private fun restartLocalCamera() {
        localStream?.dispose()
        localStream = null

        views.removeAll { it.get() == null }

        // Disconnecting also happens when the screen goes away. Reopening the
        // camera then would hold the device — and its recording indicator —
        // open with nothing rendering it.
        if (views.isEmpty()) return

        startLocalCamera()
    }

    // ── Observation ──────────────────────────────────────────────────────

    private fun observe() {
        cancelObservation()
        val realtime = client?.realtime ?: return

        stateJob = scope.launch {
            realtime.connectionState.collect { state -> emit(state.wire()) }
        }
        errorJob = scope.launch {
            realtime.errors.collect { error -> emit("error", error.message) }
        }
        remoteJob = scope.launch {
            realtime.remoteStreamUpdates.collect { stream ->
                remoteStream = stream
                rebindViews()
            }
        }
    }

    private fun cancelObservation() {
        stateJob?.cancel(); stateJob = null
        errorJob?.cancel(); errorJob = null
        remoteJob?.cancel(); remoteJob = null
    }

    /**
     * A live session bills continuously, so it is not left running on a screen
     * nobody is watching. Zero or less disables the cap.
     */
    private fun scheduleAutoDisconnect(seconds: Double) {
        autoDisconnectJob?.cancel()
        if (seconds <= 0) return

        autoDisconnectJob = scope.launch {
            delay((seconds * 1000).toLong())
            disconnect()
            emit(
                "disconnected",
                "Session ended automatically after ${seconds.toInt()}s to limit credit use.",
            )
        }
    }

    // ── Views ────────────────────────────────────────────────────────────

    fun register(view: DecartVideoPlatformView) {
        views.removeAll { it.get() == null }
        views.add(WeakReference(view))
        bind(view)
    }

    fun unregister(view: DecartVideoPlatformView) {
        views.removeAll { it.get() == null || it.get() === view }
    }

    private fun rebindViews() {
        views.removeAll { it.get() == null }
        views.forEach { ref -> ref.get()?.let(::bind) }
    }

    private fun bind(view: DecartVideoPlatformView) {
        val stream = streamFor(view.source)
        view.attach(stream?.videoTrack, stream?.room)
    }

    private fun streamFor(source: DecartVideoSource): RealtimeMediaStream? = when (source) {
        DecartVideoSource.LOCAL -> localStream
        DecartVideoSource.REMOTE -> remoteStream
        DecartVideoSource.AUTO -> remoteStream ?: localStream
    }

    // ── Helpers ──────────────────────────────────────────────────────────

    private fun emit(state: String, message: String? = null) {
        onEvent?.invoke(state, message)
    }

    private fun ByteArray.toBase64(): String = Base64.encodeToString(this, Base64.NO_WRAP)

    /** Match the strings the iOS bridge emits, so Dart maps one set of names. */
    private fun ConnectionState.wire(): String = name.lowercase()
}

/** Convenience so callers can read the current track types without casting. */
internal typealias DecartTrack = VideoTrack

/** Convenience alias mirroring the LiveKit type used by the platform view. */
internal typealias DecartRoom = Room

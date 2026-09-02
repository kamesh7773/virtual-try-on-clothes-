package com.livelook.app.decart

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.livekit.android.renderer.TextureViewRenderer
import io.livekit.android.room.Room
import io.livekit.android.room.track.VideoTrack
import livekit.org.webrtc.RendererCommon

object DecartVideoViewType {
    /** Keep in sync with `DecartVideoView.viewType` on the Dart side. */
    const val ID = "livelook/decart_video"
}

/** Builds one [DecartVideoPlatformView] per `AndroidView` in the widget tree. */
class DecartVideoViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?>
        val source = DecartVideoSource.fromWire(params?.get("source") as? String)
        return DecartVideoPlatformView(context, source)
    }
}

/**
 * Renders one Decart video feed inside the Flutter widget tree.
 *
 * The track is not owned here: [DecartSessionBridge] hands one over whenever
 * the session produces or drops it.
 *
 * A `TextureViewRenderer` is bound to the `EglBase` of the Room it was
 * initialised against, and re-initialising one against a different `EglBase`
 * is not reliable — so a new Room means a brand new renderer rather than a
 * rebind. Ending a session creates a fresh camera stream, and with it a fresh
 * Room, so this path runs every time.
 */
class DecartVideoPlatformView(
    private val context: Context,
    val source: DecartVideoSource,
) : PlatformView {

    private val container = FrameLayout(context).apply {
        setBackgroundColor(Color.BLACK)
    }

    private var renderer: TextureViewRenderer? = null
    private var boundTrack: VideoTrack? = null
    private var boundRoom: Room? = null

    init {
        DecartSessionBridge.register(this)
    }

    override fun getView(): View = container

    fun attach(track: VideoTrack?, room: Room?) {
        if (room == null) {
            releaseRenderer()
            return
        }

        if (room !== boundRoom) {
            releaseRenderer()
            createRenderer(room)
        }

        val active = renderer ?: return
        if (track === boundTrack) return

        boundTrack?.runCatching { removeRenderer(active) }
        track?.addRenderer(active)
        boundTrack = track
    }

    private fun createRenderer(room: Room) {
        val created = TextureViewRenderer(context)
        created.init(room.lkObjects.eglBase.eglBaseContext, null)
        created.setEnableHardwareScaler(true)
        // Fill rather than letterbox: this is a mirror, and black bars around
        // a person read as a bug.
        created.setScalingType(RendererCommon.ScalingType.SCALE_ASPECT_FILL)
        // The capture stream is already mirrored by MirrorMode.AUTO; mirroring
        // again here would undo it.
        created.setMirror(false)

        container.addView(
            created,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )

        renderer = created
        boundRoom = room
        boundTrack = null
    }

    private fun releaseRenderer() {
        val active = renderer ?: return
        boundTrack?.runCatching { removeRenderer(active) }
        boundTrack = null
        container.removeView(active)
        runCatching { active.release() }
        renderer = null
        boundRoom = null
    }

    override fun dispose() {
        DecartSessionBridge.unregister(this)
        releaseRenderer()
    }
}

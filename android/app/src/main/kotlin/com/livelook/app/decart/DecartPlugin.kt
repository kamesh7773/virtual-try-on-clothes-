package com.livelook.app.decart

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * Bridges [DecartSessionBridge] to Dart.
 *
 * Commands arrive on a method channel; connection state and errors go back on
 * an event channel, because they originate in the SDK rather than in response
 * to any one call. Channel names and payloads match the iOS plugin exactly, so
 * the Dart side is platform-agnostic.
 */
class DecartPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private companion object {
        const val METHOD_CHANNEL = "livelook/decart"
        const val EVENT_CHANNEL = "livelook/decart/events"
    }

    private val scope = CoroutineScope(Dispatchers.Main.immediate + SupervisorJob())

    private lateinit var methods: MethodChannel
    private lateinit var events: EventChannel
    private var sink: EventChannel.EventSink? = null
    private var context: Context? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        methods = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        methods.setMethodCallHandler(this)

        events = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        events.setStreamHandler(this)

        binding.platformViewRegistry.registerViewFactory(
            DecartVideoViewType.ID,
            DecartVideoViewFactory(),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
        DecartSessionBridge.onEvent = null
        scope.cancel()
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                val apiKey = call.argument<String>("apiKey")
                val httpBaseUrl = call.argument<String>("baseUrl")
                val wsBaseUrl = call.argument<String>("wsBaseUrl")
                val model = call.argument<String>("model")
                val ctx = context

                if (apiKey.isNullOrEmpty() || httpBaseUrl == null || model == null || ctx == null) {
                    result.invalidArgs("initialize needs apiKey, baseUrl and model")
                    return
                }

                runCatching {
                    DecartSessionBridge.initialize(
                        context = ctx,
                        apiKey = apiKey,
                        httpBaseUrl = httpBaseUrl,
                        // The SDK signals over wss and calls REST over https.
                        // Derive the socket URL when Dart did not supply one.
                        wsBaseUrl = wsBaseUrl?.takeIf { it.isNotEmpty() }
                            ?: httpBaseUrl.replaceFirst("https://", "wss://")
                                .replaceFirst("http://", "ws://"),
                        modelName = model,
                    )
                }.reply(result)
            }

            "connect" -> {
                val prompt = call.argument<String>("prompt")
                if (prompt == null) {
                    result.invalidArgs("connect needs a prompt")
                    return
                }
                val image = call.argument<ByteArray>("image")
                val seconds = call.argument<Double>("autoDisconnectSeconds") ?: 0.0

                scope.launch {
                    runCatching {
                        DecartSessionBridge.connect(prompt, image, seconds)
                    }.reply(result)
                }
            }

            "setGarment" -> {
                val prompt = call.argument<String>("prompt")
                if (prompt == null) {
                    result.invalidArgs("setGarment needs a prompt")
                    return
                }
                val image = call.argument<ByteArray>("image")

                scope.launch {
                    runCatching {
                        DecartSessionBridge.setGarment(prompt, image)
                    }.reply(result)
                }
            }

            "disconnect" -> scope.launch {
                runCatching { DecartSessionBridge.disconnect() }.reply(result)
            }

            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
        this.sink = sink
        DecartSessionBridge.onEvent = { state, message ->
            val payload = mutableMapOf<String, Any>("state" to state)
            if (message != null) payload["message"] = message
            this.sink?.success(payload)
        }
    }

    override fun onCancel(arguments: Any?) {
        sink = null
        DecartSessionBridge.onEvent = null
    }
}

private fun MethodChannel.Result.invalidArgs(message: String) =
    error("invalid_arguments", message, null)

/**
 * Answers the channel for a call that returns nothing.
 *
 * `fold(result::success, ...)` cannot be used here: `runCatching` produces a
 * `Result<Unit>`, and Kotlin resolves `success` to the member taking `Any?`
 * (members always beat extensions), so `kotlin.Unit` reaches the Flutter codec
 * and it throws "Unsupported value".
 */
private fun Result<Unit>.reply(result: MethodChannel.Result) = fold(
    onSuccess = { result.success(null) },
    onFailure = { result.error("decart_error", it.message ?: it.toString(), null) },
)

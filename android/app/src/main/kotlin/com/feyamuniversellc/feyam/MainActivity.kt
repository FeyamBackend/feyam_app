package com.feyamuniversellc.feyam

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

// flutter_stripe requiere que la Activity extienda FlutterFragmentActivity.
class MainActivity : FlutterFragmentActivity() {
    private val shareChannelName = "com.feyamuniversellc.feyam/share"
    private var pendingUrl: String? = null
    private var eventSink: EventChannel.EventSink? = null
    private var intentHandled = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, shareChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
                    eventSink = sink
                    pendingUrl?.let {
                        sink.success(it)
                        pendingUrl = null
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    override fun onResume() {
        super.onResume()
        if (!intentHandled) {
            intentHandled = true
            extractSharedUrl(intent)?.let { url ->
                if (eventSink != null) {
                    eventSink?.success(url)
                } else {
                    pendingUrl = url
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intentHandled = false
    }

    private fun extractSharedUrl(intent: Intent?): String? {
        if (intent?.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            return intent.getStringExtra(Intent.EXTRA_TEXT)
        }
        return null
    }
}

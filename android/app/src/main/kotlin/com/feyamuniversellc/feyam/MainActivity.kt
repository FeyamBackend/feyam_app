package com.feyamuniversellc.feyam

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

// flutter_stripe requiere que la Activity extienda FlutterFragmentActivity.
class MainActivity : FlutterFragmentActivity() {
    private val shareChannelName = "com.feyamuniversellc.feyam/share"
    private var pendingShare: Map<String, String>? = null
    private var eventSink: EventChannel.EventSink? = null
    private var intentHandled = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, shareChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
                    eventSink = sink
                    pendingShare?.let {
                        sink.success(it)
                        pendingShare = null
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
            extractSharedContent(intent)?.let { share ->
                if (eventSink != null) {
                    eventSink?.success(share)
                } else {
                    pendingShare = share
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intentHandled = false
    }

    private fun extractSharedContent(intent: Intent?): Map<String, String>? {
        if (intent?.action != Intent.ACTION_SEND || intent.type != "text/plain") {
            return null
        }
        return ShareTextParser.parse(intent.getStringExtra(Intent.EXTRA_TEXT))
    }
}

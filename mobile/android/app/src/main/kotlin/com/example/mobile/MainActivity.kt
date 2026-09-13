package com.example.mobile

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.mobile/share_intent"
    private var methodChannel: MethodChannel? = null
    private var pendingSharedText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleSendIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialSharedText" -> {
                        val text = pendingSharedText
                        pendingSharedText = null
                        result.success(text)
                    }
                    "clearSharedText" -> {
                        pendingSharedText = null
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleSendIntent(intent)

        // If Flutter engine is already running, push directly via channel
        val text = pendingSharedText
        if (text != null && methodChannel != null) {
            methodChannel?.invokeMethod("onSharedTextReceived", text)
            pendingSharedText = null
        }
    }

    private fun handleSendIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        val type = intent.type

        if (Intent.ACTION_SEND == action && type != null) {
            if ("text/plain" == type || type.startsWith("text/")) {
                val shared = intent.getStringExtra(Intent.EXTRA_TEXT)
                if (!shared.isNullOrBlank()) {
                    pendingSharedText = shared
                }
            }
        }
    }
}

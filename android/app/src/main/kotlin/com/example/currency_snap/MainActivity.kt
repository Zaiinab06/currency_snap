package com.example.currency_snap

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.currency_snap/widget"
    private var autoFocusAmount: Boolean = false
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Check if app was opened with auto_focus_amount extra
        if (intent?.getBooleanExtra("auto_focus_amount", false) == true) {
            autoFocusAmount = true
        }

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAutoFocusAmount" -> {
                        val shouldFocus = autoFocusAmount
                        autoFocusAmount = false
                        result.success(shouldFocus)
                    }
                    "clearAutoFocusAmount" -> {
                        autoFocusAmount = false
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
        val shouldFocus = intent.getBooleanExtra("auto_focus_amount", false)
        if (shouldFocus) {
            autoFocusAmount = true
            methodChannel?.invokeMethod("onAutoFocusAmount", true)
        }
    }
}

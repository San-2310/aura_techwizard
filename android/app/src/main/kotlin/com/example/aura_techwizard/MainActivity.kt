package com.example.aura_techwizard

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.PowerManager
import android.content.Context

class MainActivity: FlutterActivity() {
    private val CHANNEL = "screen_monitor"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isScreenActive") {
                val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                val isScreenOn = powerManager.isInteractive
                
                if (isScreenOn) {
                    // Start tracking time
                    val startTime = System.currentTimeMillis()
                    
                    // Check again after 2 minutes
                    android.os.Handler().postDelayed({
                        if (powerManager.isInteractive) {
                            val endTime = System.currentTimeMillis()
                            val screenActiveTime = endTime - startTime
                            
                            // If screen was active for more than 2 minutes
                            result.success(screenActiveTime >= 120000) // 2 minutes in milliseconds
                        } else {
                            result.success(false)
                        }
                    }, 120000) // 2 minutes delay
                } else {
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
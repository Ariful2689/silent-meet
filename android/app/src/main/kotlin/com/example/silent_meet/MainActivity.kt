package com.example.silent_meet

import android.app.NotificationManager
import android.content.Intent
import android.media.AudioManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// Business Logic Layer (native side).
/// Bridges Flutter to Android's AudioManager/NotificationManager so the
/// app can actually change the device's ringer mode. This requires the
/// user to have granted "Do Not Disturb access" to the app — Android
/// does not allow apps to change ringer mode silently without it.
class MainActivity : FlutterActivity() {
    private val CHANNEL = "silent_meet/ringer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val notificationManager =
                getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager

            when (call.method) {
                "hasDndAccess" -> {
                    result.success(notificationManager.isNotificationPolicyAccessGranted)
                }
                "requestDndAccess" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                    startActivity(intent)
                    result.success(null)
                }
                "setRingerMode" -> {
                    if (!notificationManager.isNotificationPolicyAccessGranted) {
                        result.error(
                            "NO_ACCESS",
                            "Do Not Disturb access not granted",
                            null
                        )
                        return@setMethodCallHandler
                    }
                    val mode = call.argument<String>("mode")
                    when (mode) {
                        "silent" -> audioManager.ringerMode = AudioManager.RINGER_MODE_SILENT
                        "vibrate" -> audioManager.ringerMode = AudioManager.RINGER_MODE_VIBRATE
                        "normal" -> audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
                        else -> {
                            result.error("BAD_ARGUMENT", "Unknown mode: $mode", null)
                            return@setMethodCallHandler
                        }
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
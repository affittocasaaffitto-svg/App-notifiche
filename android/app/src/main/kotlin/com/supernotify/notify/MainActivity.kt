package com.supernotify.notify

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.provider.Settings
import android.text.TextUtils
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val methodChannel = "com.supernotify/notifications"
    private val eventChannel = "com.supernotify/notification_stream"
    private var eventSink: EventChannel.EventSink? = null
    private var receiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // MethodChannel: controllo permessi + apertura impostazioni
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isPermissionGranted" -> result.success(isNotificationServiceEnabled())
                    "isServiceConnected" ->
                        result.success(SuperNotifyListenerService.isConnected)
                    "openSettings" -> {
                        try {
                            startActivity(
                                Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            )
                        } catch (e: Exception) {
                            startActivity(Intent(Settings.ACTION_SETTINGS))
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        // EventChannel: stream di notifiche in arrivo
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannel)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
                    eventSink = sink
                    registerNotificationReceiver()
                }

                override fun onCancel(args: Any?) {
                    unregisterNotificationReceiver()
                    eventSink = null
                }
            })
    }

    private fun registerNotificationReceiver() {
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                intent ?: return
                val data = mapOf(
                    "package" to intent.getStringExtra(
                        SuperNotifyListenerService.EXTRA_PACKAGE),
                    "title" to intent.getStringExtra(
                        SuperNotifyListenerService.EXTRA_TITLE),
                    "text" to intent.getStringExtra(
                        SuperNotifyListenerService.EXTRA_TEXT),
                    "time" to intent.getLongExtra(
                        SuperNotifyListenerService.EXTRA_TIME, 0L)
                )
                eventSink?.success(data)
            }
        }
        LocalBroadcastManager.getInstance(this).registerReceiver(
            receiver!!,
            IntentFilter(SuperNotifyListenerService.ACTION_NOTIFICATION_POSTED)
        )
    }

    private fun unregisterNotificationReceiver() {
        receiver?.let {
            LocalBroadcastManager.getInstance(this).unregisterReceiver(it)
        }
        receiver = null
    }

    /** Verifica se l'app ha l'accesso al servizio notifiche */
    private fun isNotificationServiceEnabled(): Boolean {
        val pkgName = packageName
        val flat = Settings.Secure.getString(
            contentResolver, "enabled_notification_listeners")
        if (!TextUtils.isEmpty(flat)) {
            val names = flat.split(":").toTypedArray()
            for (name in names) {
                val componentName =
                    android.content.ComponentName.unflattenFromString(name)
                if (componentName != null && TextUtils.equals(
                        pkgName, componentName.packageName)) {
                    return true
                }
            }
        }
        return false
    }
}


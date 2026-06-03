package com.supernotify.notify

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Riattiva il NotificationListenerService dopo il riavvio del dispositivo.
 * Essenziale su Xiaomi/MIUI, dove il sistema spesso non ricollega
 * automaticamente i listener dopo il boot.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return
        val action = intent.action ?: return
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == Intent.ACTION_LOCKED_BOOT_COMPLETED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            Log.d("SuperNotifyBoot", "Boot completato - richiedo rebind del listener")
            try {
                SuperNotifyListenerService.forceRebind(context.applicationContext)
            } catch (e: Exception) {
                Log.e("SuperNotifyBoot", "Errore rebind dopo boot: ${e.message}")
            }
        }
    }
}

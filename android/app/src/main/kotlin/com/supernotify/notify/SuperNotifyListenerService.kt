package com.supernotify.notify

import android.app.Notification
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager

/**
 * Servizio nativo che intercetta le notifiche di sistema.
 * Funziona solo dopo che l'utente concede "Accesso alle notifiche"
 * nelle Impostazioni di Android.
 */
class SuperNotifyListenerService : NotificationListenerService() {

    companion object {
        const val ACTION_NOTIFICATION_POSTED =
            "com.supernotify.notify.NOTIFICATION_POSTED"
        const val EXTRA_PACKAGE = "package"
        const val EXTRA_TITLE = "title"
        const val EXTRA_TEXT = "text"
        const val EXTRA_TIME = "time"
        private const val TAG = "SuperNotifyListener"

        // Indica se il servizio è attualmente connesso al sistema
        @Volatile var isConnected = false
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        isConnected = true
        Log.d(TAG, "Listener connesso al sistema")
        // Quando il servizio si connette, processa le notifiche già presenti
        try {
            activeNotifications?.forEach { handleNotification(it) }
        } catch (e: Exception) {
            Log.e(TAG, "Errore lettura notifiche attive: ${e.message}")
        }
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        isConnected = false
        Log.d(TAG, "Listener disconnesso - tento riconnessione")
        // Su Android 7+ richiede la riconnessione del listener
        try {
            requestRebind(
                android.content.ComponentName(this, SuperNotifyListenerService::class.java)
            )
        } catch (e: Exception) {
            Log.e(TAG, "Errore rebind: ${e.message}")
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn ?: return
        handleNotification(sbn)
    }

    private fun handleNotification(sbn: StatusBarNotification) {
        try {
            val extras = sbn.notification.extras

            val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
            var text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
            // Fallback su BigText se text è vuoto
            if (text.isBlank()) {
                text = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() ?: ""
            }
            val packageName = sbn.packageName ?: ""
            val time = sbn.postTime

            // Ignora notifiche vuote o del proprio servizio
            if (packageName == this.packageName) return
            if (title.isBlank() && text.isBlank()) return

            Log.d(TAG, "Notifica da $packageName: $title - $text")

            val intent = Intent(ACTION_NOTIFICATION_POSTED).apply {
                putExtra(EXTRA_PACKAGE, packageName)
                putExtra(EXTRA_TITLE, title)
                putExtra(EXTRA_TEXT, text)
                putExtra(EXTRA_TIME, time)
            }
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Errore handleNotification: ${e.message}")
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        // Gestione rimozione notifiche (non necessaria per ora)
    }
}

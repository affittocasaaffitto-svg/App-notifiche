package com.supernotify.notify

import android.app.Notification
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.localbroadcastmanager.content.LocalBroadcastManager

/**
 * Servizio nativo che intercetta le notifiche di sistema.
 * Funziona solo dopo che l'utente concede "Accesso alle notifiche"
 * nelle Impostazioni di Android (Settings > Notifiche > Accesso alle notifiche).
 *
 * Quando arriva una notifica, ne estrae i dati e li inoltra
 * al lato Flutter tramite un broadcast / EventChannel.
 */
class SuperNotifyListenerService : NotificationListenerService() {

    companion object {
        const val ACTION_NOTIFICATION_POSTED =
            "com.supernotify.supernotify_ai.NOTIFICATION_POSTED"
        const val EXTRA_PACKAGE = "package"
        const val EXTRA_TITLE = "title"
        const val EXTRA_TEXT = "text"
        const val EXTRA_TIME = "time"
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn ?: return
        val extras = sbn.notification.extras

        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
        val packageName = sbn.packageName ?: ""
        val time = sbn.postTime

        // Ignora notifiche vuote o del proprio servizio
        if (packageName == this.packageName) return
        if (title.isBlank() && text.isBlank()) return

        val intent = Intent(ACTION_NOTIFICATION_POSTED).apply {
            putExtra(EXTRA_PACKAGE, packageName)
            putExtra(EXTRA_TITLE, title)
            putExtra(EXTRA_TEXT, text)
            putExtra(EXTRA_TIME, time)
        }
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        // Possibile gestione della rimozione notifiche
    }
}

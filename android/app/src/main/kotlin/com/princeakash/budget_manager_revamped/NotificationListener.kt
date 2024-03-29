package com.princeakash.budget_manager_revamped

import android.annotation.SuppressLint
import android.app.Notification
import android.content.Intent
import android.os.Build.VERSION_CODES
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.annotation.RequiresApi
import android.util.Log;

@SuppressLint("OverrideAbstract")
@RequiresApi(api = VERSION_CODES.JELLY_BEAN_MR2)
class NotificationListener : NotificationListenerService() {
    companion object {
        val NOTIFICATION_INTENT = "com.princeakash.budget_manager_revamped.NOTIFICATION"
        val NOTIFICATION_PACKAGE_NAME = "notification_package_name"
        val NOTIFICATION_MESSAGE = "notification_message"
        val NOTIFICATION_TITLE = "notification_title"
        val MESSAGER_PACKAGE = "com.google.android.apps.messaging"
        val PAYTM_PACKAGE = "net.one97.paytm"
        val PHONEPE_PACKAGE = "com.phonepe.app"
        val GPAY_PACKAGE = "com.google.android.apps.nbu.paisa.user"
        val SBI_PACKAGE = "com.sbi.lotusintouch"
        val ICICI_PACKAGE = "com.csam.icici.bank.imobile"
        val TAG = "NotificationListener"
        val allowedPackages =
            listOf(PAYTM_PACKAGE, PHONEPE_PACKAGE, GPAY_PACKAGE, SBI_PACKAGE, ICICI_PACKAGE)
    }

    override fun onNotificationPosted(notification: StatusBarNotification) {
        val packageName: String = notification.getPackageName()
        if (!Companion.allowedPackages.contains(packageName)) {
            return
        }

        val extras: Bundle? = notification.getNotification().extras
        if (extras != null) {
            val intent =
                Intent(NOTIFICATION_INTENT, null, this, NotificationBroadcastReceiver::class.java)
            val title: CharSequence? = extras.getCharSequence(Notification.EXTRA_TITLE)
            val text: CharSequence? = extras.getCharSequence(Notification.EXTRA_TEXT)
            intent.putExtra(NOTIFICATION_PACKAGE_NAME, packageName)
            intent.putExtra(NOTIFICATION_TITLE, title?.toString())
            intent.putExtra(NOTIFICATION_MESSAGE, text?.toString())
            sendBroadcast(intent)
        }
    }
}
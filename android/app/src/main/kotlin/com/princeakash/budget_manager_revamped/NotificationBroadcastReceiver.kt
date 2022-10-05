package com.princeakash.budget_manager_revamped

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.view.FlutterMain


class NotificationBroadcastReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "NotificationBroadcastReceiver"
    }
    override fun onReceive(context: Context, intent: Intent) {
        Log.e(TAG, "onReceive!")
        FlutterMain.startInitialization(context)
        FlutterMain.ensureInitializationComplete(context, null)
        NotificationPropagationService.enqueueWork(context, intent)
    }
}
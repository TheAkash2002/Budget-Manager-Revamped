package com.princeakash.budget_manager_revamped

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.Manifest
import android.app.Activity
import android.app.PendingIntent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Telephony

import android.app.Notification;
import android.content.ComponentName;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import androidx.annotation.NonNull;

import androidx.annotation.RequiresApi;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    companion object {
        @JvmStatic
        val TAG = "MainActivity"

        @JvmStatic
        val SHARED_PREFERENCES_KEY = "notification_propagation_cache"

        @JvmStatic
        val SETUP_BACKGROUND_CHANNEL_FOR_DB_ENTRY_HANDLE_KEY =
            "setup_background_channel_for_db_entry_handler"

        @JvmStatic
        val MAIN_CHANNEL_TAG = "princeAkash/main"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, MAIN_CHANNEL_TAG
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                /**
                 * Initialize service with the callback handle to setup a background channel to
                 * interact with dbEntryFunction.
                 */
                "initializeService" -> {
                    if (notifReadingPermissionGranted()) {
                        val args = call.arguments<ArrayList<*>>()
                        initializeService(args)
                        result.success(true)
                    } else {
                        Log.e(
                            TAG,
                            "Failed to start notification tracking; Permissions were not yet granted."
                        )
                        result.success(false)
                    }
                }

                "checkNotifReadingPermission" -> {
                    result.success(notifReadingPermissionGranted());
                }

                "requestNotifReadingPermission" -> {
                    requestNotifReadingPermission();
                    result.success(true);
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Initialize service to listen to notifications.
     */
    private fun initializeService(args: ArrayList<*>?) {
        Log.d(TAG, "Initializing NotificationPropagationService")
        val callbackHandle = args!![0] as Long
        getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE).edit()
            .putLong(SETUP_BACKGROUND_CHANNEL_FOR_DB_ENTRY_HANDLE_KEY, callbackHandle).apply()

        /*val intentFilter = IntentFilter()
        intentFilter.addAction(NotificationListener.NOTIFICATION_INTENT)
        intentFilter.addAction(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
        registerReceiver(NotificationBroadcastReceiver(), intentFilter)*/

        val listenerIntent = Intent(context, NotificationListener::class.java)
        startService(listenerIntent)
        Log.i(TAG, "Started the notification relaying service.")
    }

    /**
     * Checks if the app has been granted permission to listen to notifications.
     */
    private fun notifReadingPermissionGranted(): Boolean {
        val packageName: String? = context.getPackageName()
        val flat: String? = Settings.Secure.getString(
            context.getContentResolver(), "enabled_notification_listeners"
        )
        if (!TextUtils.isEmpty(flat)) {
            val names: List<String> = flat!!.split(":")
            for (name in names) {
                val componentName: ComponentName? = ComponentName.unflattenFromString(name)
                val nameMatch: Boolean =
                    TextUtils.equals(packageName!!, componentName!!.getPackageName())
                if (nameMatch) {
                    return true;
                }
            }
        }
        return false
    }

    /**
     * Opens the Settings screen to allow app to listen to notifications, if permission is not
     * already granted.
     */
    fun requestNotifReadingPermission() {
        /// Sort out permissions for notifications
        if (!notifReadingPermissionGranted()) {
            val permissionScreen = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
            permissionScreen.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(permissionScreen)
        }
    }
}

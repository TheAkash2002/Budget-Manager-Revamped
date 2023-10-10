// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.princeakash.budget_manager_revamped

import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.os.PowerManager
import android.os.Handler
import android.util.Log
import androidx.core.app.JobIntentService
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain
import io.flutter.view.FlutterNativeView
import io.flutter.view.FlutterRunArguments
import java.util.ArrayDeque
import java.util.concurrent.atomic.AtomicBoolean
import java.util.UUID
import android.provider.Telephony

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback

class NotificationPropagationService : MethodCallHandler, JobIntentService() {
    private val queue = ArrayDeque<List<String?>>()
    private lateinit var mBackgroundChannel: MethodChannel
    private lateinit var mContext: Context

    companion object {
        @JvmStatic
        private val TAG = "NotificationPropagationService"

        @JvmStatic
        private val BACKGROUND_CHANNEL_TAG = "princeAkash/background"

        @JvmStatic
        private val JOB_ID = UUID.randomUUID().mostSignificantBits.toInt()

        @JvmStatic
        private var sBackgroundFlutterEngine: FlutterEngine? = null

        @JvmStatic
        private val sBackgroundEngineInitiated = AtomicBoolean(false)

        @JvmStatic
        private lateinit var sPluginRegistrantCallback: PluginRegistrantCallback

        @JvmStatic
        fun enqueueWork(context: Context, work: Intent) {
            enqueueWork(context, NotificationPropagationService::class.java, JOB_ID, work)
        }

        @JvmStatic
        fun setPluginRegistrant(callback: PluginRegistrantCallback) {
            sPluginRegistrantCallback = callback
        }
    }

    /**
     * Setup sBackgroundFlutterEngine and establish two-way contact with Dart code on background
     * channel.
     */
    private fun startPropagationService(context: Context) {
        synchronized(sBackgroundEngineInitiated) {
            mContext = context
            if (sBackgroundFlutterEngine == null) {
                sBackgroundFlutterEngine = FlutterEngine(context)

                val setupBackgroundChannelForDbEntryHandle = context.getSharedPreferences(
                    MainActivity.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE
                ).getLong(MainActivity.SETUP_BACKGROUND_CHANNEL_FOR_DB_ENTRY_HANDLE_KEY, 0)
                if (setupBackgroundChannelForDbEntryHandle == 0L) {
                    Log.e(TAG, "Fatal: no setupBackgroundChannelForDbEntry method registered")
                    return
                }

                val setupBackgroundChannelForDbEntryCallbackInfo =
                    FlutterCallbackInformation.lookupCallbackInformation(
                        setupBackgroundChannelForDbEntryHandle
                    )
                if (setupBackgroundChannelForDbEntryCallbackInfo == null) {
                    Log.e(TAG, "Fatal: failed to find setupBackgroundChannelForDbEntry method")
                    return
                }

                val args = DartCallback(
                    context.getAssets(),
                    FlutterMain.findAppBundlePath(context)!!,
                    setupBackgroundChannelForDbEntryCallbackInfo
                )
                sBackgroundFlutterEngine!!.getDartExecutor().executeDartCallback(args)
                Log.e(TAG, "Connected to Flutter")
                //IsolateHolderService.setBackgroundFlutterEngine(sBackgroundFlutterEngine)
            }
        }

        mBackgroundChannel = MethodChannel(
            sBackgroundFlutterEngine!!.getDartExecutor().getBinaryMessenger(),
            BACKGROUND_CHANNEL_TAG
        )
        mBackgroundChannel.setMethodCallHandler(this)
    }

    /**
     * Invoked after the Dart code responds back with an initiated event, indicating that the
     * background channel method call handler to insert values into database has been set to
     * monitor the subsequent background channel method calls.
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "NotificationPropagationService.initialized" -> {
                synchronized(sBackgroundEngineInitiated) {
                    while (!queue.isEmpty()) {
                        mBackgroundChannel.invokeMethod("", queue.remove())
                    }
                    sBackgroundEngineInitiated.set(true)
                }
            }

            else -> result.notImplemented()
        }
        result.success(null)
    }

    override fun onCreate() {
        super.onCreate()
        startPropagationService(this)
    }

    /**
     * Invoked when work received from NotificationBroadcastReceiver can be handled. If the
     * sBackgroundFlutterEngine is not ready, work is queued. Otherwise, notification payload is
     * relayed immediately to background channel.
     */
    override fun onHandleWork(intent: Intent) {
        val isNotification: Boolean =
            (intent.action.equals(NotificationListener.NOTIFICATION_INTENT))
        val notificationUpdateList: List<String?> =
            if (isNotification) getUpdateListFromNotification(intent) else getUpdateListFromTextMessage(
                intent
            )

        synchronized(sBackgroundEngineInitiated) {
            if (!sBackgroundEngineInitiated.get()) {
                // Queue up notification events while background isolate is starting
                queue.add(notificationUpdateList)
            } else {
                // Callback method name is intentionally left blank.
                Handler(mContext.mainLooper).post {
                    mBackgroundChannel.invokeMethod("", notificationUpdateList)
                }
            }
        }
    }

    /**
     * Gets payload from text message through Intent.
     */
    fun getUpdateListFromTextMessage(intent: Intent): List<String?> {
        val smsMessages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        for (message in smsMessages) {
            return listOf(
                NotificationListener.MESSAGER_PACKAGE,
                message.displayOriginatingAddress,
                message.messageBody
            )
        }
        return listOf(NotificationListener.MESSAGER_PACKAGE, "None", "None")
    }

    /**
     * Gets payload from notification through Intent.
     */
    fun getUpdateListFromNotification(intent: Intent): List<String?> {
        val packageName: String? =
            intent.getStringExtra(NotificationListener.NOTIFICATION_PACKAGE_NAME)
        val title: String? = intent.getStringExtra(NotificationListener.NOTIFICATION_TITLE)
        val message: String? = intent.getStringExtra(NotificationListener.NOTIFICATION_MESSAGE)
        return listOf(packageName, title, message)
    }
}

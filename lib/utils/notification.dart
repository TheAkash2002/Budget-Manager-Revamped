import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../db/firestore_helper.dart';
import '../firebase_options.dart';
import '../models/models.dart';
import 'permissions.dart';
import 'utils.dart';

const BACKGROUND_METHOD_CHANNEL_NAME = 'princeAkash/background';

/**
 * Basic Util
 */

bool isNotifReadingSupported() => Platform.isAndroid;

/**
 *  Notification Reader
 */

Future<bool> initializeNotificationReaderService() async {
  final CallbackHandle? callbackHandle =
      PluginUtilities.getCallbackHandle(setupBackgroundChannelForDbEntry);
  dynamic isInitialized = await mainMethodChannel.invokeMethod(
      'initializeService', <dynamic>[callbackHandle!.toRawHandle()]);
  if (isInitialized != null && isInitialized == true) {
    log.warning('Initialized service successfully.');
    return true;
  } else {
    if (isInitialized == null) {
      log.warning('Error in initialization');
    } else {
      log.warning(isInitialized);
      log.warning('Initialization returned false.');
    }
  }
  return false;
}

@pragma('vm:entry-point')
void setupBackgroundChannelForDbEntry() async {
  const MethodChannel _backgroundChannel =
      MethodChannel(BACKGROUND_METHOD_CHANNEL_NAME);
  WidgetsFlutterBinding.ensureInitialized();
  _backgroundChannel.setMethodCallHandler((MethodCall call) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final List<dynamic> args = call.arguments;
      final String senderWithContent =
          '${args[1] as String} ${args[2] as String}';
      CapturedNotification cn = CapturedNotification(
          args[0] as String?, args[1] as String?, senderWithContent);
      if (cn.isUnknown()) {
        return;
      }
      Expense? inserted = await insertExpenseFromCapturedNotification(cn);
      if (inserted != null) {
        dispatchNotification('Added expense: Rs.${inserted.amount.toString()}',
            'Success!', inserted.id);
      }
    } on Exception catch (e) {
      log.severe(e);
    }
  });
  _backgroundChannel.invokeMethod('NotificationPropagationService.initialized');
}

Future<Expense?> insertExpenseFromCapturedNotification(
    CapturedNotification cn) async {
  DateTime current = DateTime.now();
  Expense newExpense = Expense(
    id: '',
    amount: cn.getAmount(),
    category: cn.getCategory(),
    description: cn.getDescription(),
    direction: cn.getDirection(),
    date: DateTime(current.year, current.month, current.day),
    lastEdit: DateTime.now(),
  );
  return await insertExpense(newExpense);
}

/**
 * Notification Sender
 */

final FlutterLocalNotificationsPlugin plugin =
    FlutterLocalNotificationsPlugin();

int id = 0;

const NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails('princeAkash/notifChannel', 'Channel',
        channelDescription: 'NotifChannel',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        actions: <AndroidNotificationAction>[
      AndroidNotificationAction('del', 'Delete'),
    ]));

Future<void> initializeNotificationSenderService() async {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launch_background');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await plugin.initialize(initializationSettings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (response.actionId == 'del') {
    deleteExpense(response.payload!);
  }
}

/// Show notification.
void dispatchNotification(String title, String message, String newId) =>
    plugin.show(id++, title, message, notificationDetails, payload: newId);

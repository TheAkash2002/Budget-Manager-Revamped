import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../db/firestore_helper.dart';
import '../firebase_options.dart';
import '../models/models.dart';
import '../notification/notification_utils.dart';
import '../utils/utils.dart';

final FlutterLocalNotificationsPlugin plugin =
    FlutterLocalNotificationsPlugin();
int id = 0;
const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('princeAkash/notifChannel', 'Channel',
        channelDescription: 'NotifChannel',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        actions: <AndroidNotificationAction>[
      AndroidNotificationAction("del", "Delete"),
    ]);
const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

const MethodChannel mainMethodChannel = MethodChannel('princeAkash/main');

/// Checks if Permissions verifiable from Flutter are granted or not.
Future<bool> hasAllRequiredPermissions() async {
  if (!await hasSmsPermission()) {
    log.warning("No SMS permission");
    return false;
  }
  if (!await hasNotifPostingPermission()) {
    log.warning("No notif posting permission");
    return false;
  }
  if (!(await hasNotifReadingPermission())!) {
    log.warning("No notif reading permission");
    return false;
  }
  return true;
}

Future<bool> hasSmsPermission() => Permission.sms.status.isGranted;

Future<bool> hasNotifPostingPermission() =>
    Permission.notification.status.isGranted;

Future<dynamic> hasNotifReadingPermission() =>
    mainMethodChannel.invokeMethod('checkNotifReadingPermission');

Future<PermissionStatus> requestSmsPermission() => Permission.sms.request();

Future<PermissionStatus> requestNotifPostingPermission() =>
    Permission.notification.request();

Future<void> requestNotifReadingPermission() =>
    mainMethodChannel.invokeMethod('requestNotifReadingPermission');

Future<bool> isSmsPermanentlyDenied() =>
    Permission.sms.status.isPermanentlyDenied;

Future<bool> isNotifPostingPermanentlyDenied() =>
    Permission.notification.status.isPermanentlyDenied;

Future<bool> initializeNotificationReaderService() async {
  final CallbackHandle? callbackHandle =
      PluginUtilities.getCallbackHandle(setupBackgroundChannelForDbEntry);
  dynamic isInitialized = await mainMethodChannel.invokeMethod(
      'initializeService', <dynamic>[callbackHandle!.toRawHandle()]);
  if (isInitialized != null && isInitialized == true) {
    log.warning("Initialized service successfully.");
    return true;
  } else {
    if (isInitialized == null) {
      log.warning("Error in initialization");
    } else {
      log.warning(isInitialized);
      log.warning("Initialization returned false.");
    }
  }
  return false;
}

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
void setupBackgroundChannelForDbEntry() async {
  const MethodChannel _backgroundChannel =
      MethodChannel('princeAkash/background');
  WidgetsFlutterBinding.ensureInitialized();
  _backgroundChannel.setMethodCallHandler((MethodCall call) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final List<dynamic> args = call.arguments;
      final String senderWithContent =
          "${args[1] as String} ${args[2] as String}";
      CapturedNotification cn = CapturedNotification(
          args[0] as String?, args[1] as String?, senderWithContent);
      if (cn.isUnknown()) {
        return;
      }
      Expense? inserted = await insertExpenseFromCapturedNotification(cn);
      if (inserted != null) {
        dispatchNotification("Added expense: Rs.${inserted.amount.toString()}",
            "Success!", inserted.id);
      }
    } on Exception catch (e) {
      log.severe(e);
    }
  });
  _backgroundChannel.invokeMethod('NotificationPropagationService.initialized');
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (response.actionId == "del") {
    deleteExpense(response.payload!);
  }
}

Future<Expense?> insertExpenseFromCapturedNotification(
    CapturedNotification cn) async {
  DateTime current = DateTime.now();
  Expense newExpense = Expense(
    id: "",
    amount: cn.getAmount(),
    category: cn.getCategory(),
    description: cn.getDescription(),
    direction: cn.getDirection(),
    date: DateTime(current.year, current.month, current.day),
    lastEdit: DateTime.now(),
  );
  return await insertExpense(newExpense);
}

void dispatchNotification(String title, String message, String newId) async {
  await plugin.show(id++, title, message, notificationDetails, payload: newId);
}

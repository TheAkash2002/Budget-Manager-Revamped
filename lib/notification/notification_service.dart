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
      AndroidNotificationAction("del", "Delete")
    ]);
const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

Future<void> initializeNotificationService() async {
  //await getNecessaryPermissions();
  final CallbackHandle? callback =
      PluginUtilities.getCallbackHandle(dbEntryFunction);
  await const MethodChannel('princeAkash/main').invokeMethod(
      'NotificationListener.initializeService',
      <dynamic>[callback!.toRawHandle()]);

  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launch_background');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await plugin.initialize(initializationSettings,
      /*onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      // ...
    },*/
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
}

Future<bool> getNecessaryPermissions() async {
  while (!(await Permission.accessNotificationPolicy.request()).isGranted) {
    if ((await Permission.accessNotificationPolicy.status)
        .isPermanentlyDenied) {
      return false;
    }
  }
  while (!(await Permission.sms.request()).isGranted) {
    if ((await Permission.sms.status).isPermanentlyDenied) {
      openAppSettings();
      return false;
    }
  }
  return true;
}

@pragma('vm:entry-point')
void dbEntryFunction() async {
  configureLogger();
  const MethodChannel _backgroundChannel =
      MethodChannel('princeAkash/background');
  WidgetsFlutterBinding.ensureInitialized();
  _backgroundChannel.setMethodCallHandler((MethodCall call) async {
    try {
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
      List values = await insertExpenseFromCapturedNotification(cn);
      double amount = values[0] as double;
      String newId = values[1];
      if (newId.isNotEmpty) {
        dispatchNotification(
            "Added expense: Rs.${amount.toString()}", "Success!", newId);
      }
    } on Exception catch (e) {
      log.severe(e);
    }
  });
  _backgroundChannel.invokeMethod('NotificationPropagationService.initialized');
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  configureLogger();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (response.actionId == "del") {
    deleteExpense(response.payload!);
  }
}

Future<List> insertExpenseFromCapturedNotification(
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
  String newId = await insertExpense(newExpense);
  return [newExpense.amount, newId];
}

void dispatchNotification(String title, String message, String newId) async {
  await plugin.show(id++, title, message, notificationDetails, payload: newId);
}

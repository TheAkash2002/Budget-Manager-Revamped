import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

Future<void> initializeNotificationServices() async {
  await initializeNotificationReaderService();
  await initializeNotificationSenderService();
}

Future<dynamic> hasPermissions() =>
    mainMethodChannel.invokeMethod('checkAllPermissions');

Future<void> getNecessaryPermissions() =>
    mainMethodChannel.invokeMethod('requestAllPermissions');

void setMainMethodChannelCallHandler(
        Future<dynamic> Function(MethodCall) handler) =>
    mainMethodChannel.setMethodCallHandler(handler);

Future<bool?> initializeNotificationReaderService() async {
  final CallbackHandle? callbackHandle =
      PluginUtilities.getCallbackHandle(setupBackgroundChannelForDbEntry);
  return mainMethodChannel.invokeMethod<bool>(
      'initializeService', <dynamic>[callbackHandle!.toRawHandle()]);
}

Future<void> initializeNotificationSenderService() async {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  configureLogger();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launch_background');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  log.warning(plugin.hashCode);
  await plugin.initialize(initializationSettings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
  log.warning("Initted");
}

@pragma('vm:entry-point')
void setupBackgroundChannelForDbEntry() async {
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
  log.warning(plugin.hashCode);
  await plugin.show(id++, title, message, notificationDetails, payload: newId);
}

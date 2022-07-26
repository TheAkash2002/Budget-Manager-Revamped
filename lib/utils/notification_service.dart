import 'dart:ui';

import 'package:budget_manager_revamped/models/models.dart';
import 'package:budget_manager_revamped/utils/notification_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'database_helper.dart';

final FlutterLocalNotificationsPlugin plugin =
    FlutterLocalNotificationsPlugin();
int id = 0;
const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
  'princeAkash/notifChannel',
  'Channel',
  channelDescription: 'NotifChannel',
  importance: Importance.max,
  priority: Priority.high,
  ticker: 'ticker',
);
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
  await plugin.initialize(
    initializationSettings,
    /*onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      // ...
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,*/
  );
}

Future<bool> getNecessaryPermissions() async{
  while(!(await Permission.accessNotificationPolicy.request()).isGranted){
    if((await Permission.accessNotificationPolicy.status).isPermanentlyDenied){
      return false;
    }
  }
  while(!(await Permission.sms.request()).isGranted){
    if((await Permission.sms.status).isPermanentlyDenied){
      openAppSettings();
      return false;
    }
  }
  return true;
}

@pragma('vm:entry-point')
void dbEntryFunction() {
  const MethodChannel _backgroundChannel =
      MethodChannel('princeAkash/background');
  WidgetsFlutterBinding.ensureInitialized();

  _backgroundChannel.setMethodCallHandler((MethodCall call) async {
    try {
      final List<dynamic> args = call.arguments;
      CapturedNotification cn = CapturedNotification(
          args[0] as String?, args[1] as String?, args[2] as String?);
      if(cn.isUnknown()){
        return;
      }
      Expense newExpense = await insertExpenseFromCapturedNotification(cn);
      dispatchNotification(
          "Added expense: Rs.${newExpense.amount.toString()}", "Success!");
    } on Exception catch (e) {
      print(e);
    }
  });
  _backgroundChannel.invokeMethod('NotificationPropagationService.initialized');
}

Future<Expense> insertExpenseFromCapturedNotification(
    CapturedNotification cn) async {
  DateTime current = DateTime.now();
  Expense newExpense = Expense(
    id: 0,
    amount: cn.getAmount(),
    category: cn.getCategory(),
    description: cn.getDescription(),
    direction: cn.getDirection(),
    date: DateTime(current.year, current.month, current.day),
    lastEdit: DateTime.now(),
  );
  await insertExpense(newExpense);
  return newExpense;
}

void dispatchNotification(String title, String message) async {
  await plugin.show(id++, title, message, notificationDetails,
      payload: 'item x');
}

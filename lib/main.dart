import 'package:budget_manager_revamped/controller/targets_controller.dart';
import 'package:budget_manager_revamped/ui/targets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/expense_controller.dart';
import 'firebase_options.dart';
import 'ui/home.dart';
import 'notification/notification_service.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  initializeNotificationService();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      getPages: [
        GetPage(
          name: '/',
          page: () => Home(),
          binding: BindingsBuilder(() {
            Get.put<ExpenseController>(ExpenseController());
          }),
        ),
        GetPage(
          name: '/targets',
          page: () => Targets(),
          binding: BindingsBuilder(() {
            Get.put<TargetsController>(TargetsController());
          }),
        ),
      ],
    );
  }
}

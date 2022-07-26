import 'package:budget_manager_revamped/controller/targets_controller.dart';
import 'package:budget_manager_revamped/ui/targets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'controller/expense_controller.dart';
import 'ui/home.dart';
import 'utils/notification_service.dart';

void main() {
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
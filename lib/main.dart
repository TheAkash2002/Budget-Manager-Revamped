import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/expense_controller.dart';
import 'controller/targets_controller.dart';
import 'firebase_options.dart';
import 'notification/notification_service.dart';
import 'ui/home.dart';
import 'ui/login.dart';
import 'ui/targets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Budget Manager - Revamped',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const Login(),
        ),
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

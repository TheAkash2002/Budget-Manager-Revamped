import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/auth_controller.dart';
import 'controller/bar_pie_controller.dart';
import 'controller/expense_controller.dart';
import 'controller/home_controller.dart';
import 'controller/relative_change_controller.dart';
import 'controller/targets_controller.dart';
import 'firebase_options.dart';
import 'ui/home_page.dart';
import 'ui/login_page.dart';
import 'utils/utils.dart';

void main() async {
  configureLogger();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Budget Manager - Revamped',
      theme: loadThemeData(),
      themeMode: ThemeMode.light,
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const Login(),
          binding: BindingsBuilder(() {
            Get.put<AuthController>(AuthController());
          }),
        ),
        GetPage(
          name: '/',
          page: () => const Home(),
          binding: BindingsBuilder(() {
            Get.put<HomeController>(HomeController());
            Get.put<ExpenseController>(ExpenseController());
            Get.put<TargetsController>(TargetsController());
            Get.put<BarPieController>(BarPieController());
            Get.put<RelativeChangeController>(RelativeChangeController());
          }),
        ),
      ],
    );
  }
}

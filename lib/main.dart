import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controller/expense_controller.dart';
import 'controller/targets_controller.dart';
import 'firebase_options.dart';
import 'notification/notification_service.dart';
import 'ui/home_page.dart';
import 'ui/login_page.dart';
import 'ui/targets_page.dart';

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
      theme: _themeData(),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const Login(),
        ),
        GetPage(
          name: '/',
          page: () => const Home(),
          binding: BindingsBuilder(() {
            Get.put<ExpenseController>(ExpenseController());
          }),
        ),
        GetPage(
          name: '/targets',
          page: () => const Targets(),
          binding: BindingsBuilder(() {
            Get.put<TargetsController>(TargetsController());
          }),
        ),
      ],
    );
  }

  ThemeData _themeData() {
    var baseTheme = ThemeData(
      primarySwatch: Colors.deepPurple,
    );
    return baseTheme.copyWith(
        textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme));
  }
}

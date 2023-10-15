import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'ui/screens/home.dart';
import 'ui/screens/login.dart';
import 'ui/screens/splash.dart';
import 'utils/theme.dart';
import 'utils/utils.dart';

void main() async {
  await initializeMainApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: FToastBuilder(),
      title: 'Budget Manager - Revamped',
      theme: loadThemeData(),
      themeMode: ThemeMode.light,
      onReady: attachFToast,
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const Splash(),
        ),
        GetPage(
          name: '/login',
          page: () => const Login(),
        ),
        GetPage(
          name: '/',
          page: () => const Home(),
        ),
      ],
    );
  }
}

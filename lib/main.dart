import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'firebase_options.dart';
import 'ui/home_page.dart';
import 'ui/login_page.dart';
import 'ui/splash_page.dart';
import 'utils/utils.dart';

void main() async {
  configureLogger();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]);
  await GetStorage.init(THEME_CONTAINER);
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

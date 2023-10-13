import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../auth/auth.dart';
import '../controller/loading_mixin.dart';
import '../notification/notification_service.dart';

class SplashController extends GetxController with LoadingMixin {
  @override
  void onInit() async {
    super.onInit();
    setLoadingState(true);
    if (!kIsWeb) {
      if (!await hasAllRequiredPermissions()) {
        await showDialog<bool?>(
            context: Get.context!,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                  title: const Text("Grant SMS and Notification Permissions"),
                  content: const Text(
                      "To enter expenses automatically and notify you about auto-added expenses, grant permissions to read your SMS, read your notifications, and send you notifications."),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Open Settings"),
                    ),
                  ],
                ));
        // try {
        //   if (!await hasSmsPermission()) {
        //     log.warning("No SMS permission here");
        //     await requestSmsPermission();
        //   }
        // } catch (e) {
        //   log.severe(e);
        // }
        //
        // log.warning("Completed SMS");
        //
        // try {
        //   if (!await hasNotifPostingPermission()) {
        //     log.warning("No Notif posting permission here");
        //     await requestNotifPostingPermission();
        //   }
        // } catch (e) {
        //   log.severe(e);
        // }
        //
        // log.warning("Completed Notif Posting");
        //
        // try {
        //   if (!await hasNotifReadingPermission()) {
        //     log.warning("No Notif reading permission here");
        //     await requestNotifReadingPermission();
        //   }
        // } catch (e) {
        //   log.severe(e);
        // }
        //
        // log.warning("Completed Notif reading");

        await openAppSettings();
        await Future.delayed(const Duration(seconds: 30));

        if (!await hasAllRequiredPermissions()) {
          await showDialog<bool?>(
              context: Get.context!,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                    title: const Text("Permissions Not Granted"),
                    content: const Text(
                        "Not all settings have been granted. Expenses will not be auto-captured. Please login to the app, open Settings and ensure all permissions are in-place, to enable auto-capture."),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Dismiss"),
                      ),
                    ],
                  ));
        }
      }
      await initializeNotificationSenderService();
      await initializeNotificationReaderService();
    }
    setLoadingState(false);
    checkLoginStatus();
  }

  void checkLoginStatus() {
    Future.delayed(const Duration(seconds: 2), () {
      if (isLoggedIn()) {
        Get.offAllNamed('/');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }
}

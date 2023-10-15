import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controller/loading_mixin.dart';
import '../ui/dialogs/grant_notif_read_permission.dart';
import '../ui/dialogs/grant_sms_notif_post_permission.dart';
import '../ui/dialogs/permissions_not_granted.dart';
import '../utils/auth.dart';
import '../utils/notification.dart';
import '../utils/permissions.dart';

/// Controller for Splash screen.
class SplashController extends GetxController with LoadingMixin {
  @override
  void onInit() async {
    super.onInit();
    setLoadingState(true);
    if (!kIsWeb) {
      if (!await hasLocalPermissions()) {
        await showDialog<bool?>(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) => const GrantSmsNotifPostPermission(),
        );
        await openAppSettings();
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!(await hasNotifReadingPermission())!) {
        await showDialog<bool?>(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) => const GrantNotifReadPermission(),
        );
        await requestNotifReadingPermission();
        await Future.delayed(const Duration(seconds: 30));
      }

      if (!await hasAllRequiredPermissions()) {
        await showDialog<bool?>(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) => const PermissionsNotGranted(),
        );
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

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/models.dart';
import '../utils/notification.dart';
import '../utils/permissions.dart';
import '../utils/utils.dart';

/// Controller for Settings page.
class SettingsController extends GetxController {
  Map<AppPermissions, AppPermissionStatus> status = {
    for (AppPermissions p in AppPermissions.values)
      p: AppPermissionStatus.loading
  };

  @override
  void onInit() async {
    super.onInit();
    for (AppPermissions perm in AppPermissions.values) {
      await refreshPermission(perm);
    }
  }

  void setStatus(AppPermissions perm, AppPermissionStatus stat) {
    status[perm] = stat;
    update();
  }

  Future<AppPermissionStatus> checkStatus(AppPermissions perm) async {
    AppPermissionStatus result = AppPermissionStatus.denied;
    if (kIsWeb) {
      return result;
    }
    switch (perm) {
      case AppPermissions.sms:
        if (await hasSmsPermission()) {
          result = AppPermissionStatus.granted;
        }
        break;
      case AppPermissions.readNotif:
        if (await hasNotifReadingPermission()) {
          result = AppPermissionStatus.granted;
        }
        break;
      case AppPermissions.postNotif:
        if (await hasNotifPostingPermission()) {
          result = AppPermissionStatus.granted;
        }
        break;
    }
    return result;
  }

  Future<void> refreshPermission(AppPermissions perm) async {
    setStatus(perm, AppPermissionStatus.loading);
    setStatus(perm, await checkStatus(perm));
  }

  Future<void> requestPermission(AppPermissions perm) async {
    setStatus(perm, AppPermissionStatus.loading);
    switch (perm) {
      case AppPermissions.sms:
        if (await isSmsPermanentlyDenied()) {
          await openAppSettings();
        } else {
          await requestSmsPermission();
        }
        break;
      case AppPermissions.readNotif:
        await requestNotifReadingPermission();
        break;
      case AppPermissions.postNotif:
        if (await isNotifPostingPermanentlyDenied()) {
          await openAppSettings();
        } else {
          await requestNotifPostingPermission();
        }
        break;
    }
  }

  Future<void> initializeReader() async {
    if (await initializeNotificationReaderService()) {
      showToast(ToastType.success, 'Started notification reading service.');
    } else {
      showToast(ToastType.error, 'Failed to start notification tracking');
    }
  }
}

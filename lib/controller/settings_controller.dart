import 'package:budget_manager_revamped/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/utils.dart';

class SettingsController extends GetxController {
  late Map<Permissions, PermissionStatus> status;

  @override
  void onInit() async {
    super.onInit();
    status = {
      for (Permissions p in Permissions.values) p: PermissionStatus.loading
    };
    update();
    for (Permissions perm in Permissions.values) {
      await refreshPermission(perm);
    }
  }

  void setStatus(Permissions perm, PermissionStatus stat) {
    status[perm] = stat;
    update();
  }

  Future<PermissionStatus> checkStatus(Permissions perm) async {
    PermissionStatus result = PermissionStatus.denied;
    switch (perm) {
      case Permissions.sms:
        if (await hasSmsPermission()) {
          result = PermissionStatus.granted;
        }
        break;
      case Permissions.read_notif:
        if (await hasNotifReadingPermission()) {
          result = PermissionStatus.granted;
        }
        break;
      case Permissions.send_notif:
        if (await hasNotifPostingPermission()) {
          result = PermissionStatus.granted;
        }
        break;
    }
    return result;
  }

  Future<void> refreshPermission(Permissions perm) async {
    log.warning("Step1 $perm");
    setStatus(perm, PermissionStatus.loading);
    log.warning("Step2 $perm");
    setStatus(perm, await checkStatus(perm));
    log.warning("Step3 $perm");
  }

  Future<void> requestPermission(Permissions perm) async {
    setStatus(perm, PermissionStatus.loading);
    switch (perm) {
      case Permissions.sms:
        if (await isSmsPermanentlyDenied()) {
          await openAppSettings();
        } else {
          await requestSmsPermission();
        }
        break;
      case Permissions.read_notif:
        await requestNotifReadingPermission();
        break;
      case Permissions.send_notif:
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
      showToast("Success", "Started notification reading service.");
    } else {
      showToast("Failed", "Failed to start notification tracking");
    }
  }
}

enum Permissions { sms, read_notif, send_notif }

enum PermissionStatus { granted, loading, denied }

extension PermIcon on PermissionStatus {
  Icon icon() {
    switch (this) {
      case PermissionStatus.granted:
        return const Icon(Icons.check);
      case PermissionStatus.loading:
        return const Icon(Icons.hourglass_bottom_outlined);
      case PermissionStatus.denied:
        return const Icon(Icons.clear);
    }
  }
}

extension PermText on Permissions {
  String text() {
    switch (this) {
      case Permissions.sms:
        return "Read SMS for auto-capturing expenses";
      case Permissions.read_notif:
        return "Read user notifications for auto-capturing expenses";
      case Permissions.send_notif:
        return "Push notifications for new expenses";
    }
  }
}

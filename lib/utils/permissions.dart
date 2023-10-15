import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'utils.dart';

const MethodChannel mainMethodChannel = MethodChannel('princeAkash/main');

Future<bool> hasAllRequiredPermissions() async {
  if (!await hasLocalPermissions()) {
    log.warning('Issue with local permissions');
    return false;
  }
  if (!(await hasNotifReadingPermission())!) {
    log.warning('No notif reading permission');
    return false;
  }
  return true;
}

/// Checks if Permissions verifiable from App Settings page are granted or not.
Future<bool> hasLocalPermissions() async {
  if (!await hasSmsPermission()) {
    log.warning('No SMS permission');
    return false;
  }
  if (!await hasNotifPostingPermission()) {
    log.warning('No notif posting permission');
    return false;
  }
  return true;
}

Future<bool> hasSmsPermission() => Permission.sms.status.isGranted;

Future<bool> hasNotifPostingPermission() =>
    Permission.notification.status.isGranted;

Future<dynamic> hasNotifReadingPermission() =>
    mainMethodChannel.invokeMethod('checkNotifReadingPermission');

Future<PermissionStatus> requestSmsPermission() => Permission.sms.request();

Future<PermissionStatus> requestNotifPostingPermission() =>
    Permission.notification.request();

Future<void> requestNotifReadingPermission() =>
    mainMethodChannel.invokeMethod('requestNotifReadingPermission');

Future<bool> isSmsPermanentlyDenied() =>
    Permission.sms.status.isPermanentlyDenied;

Future<bool> isNotifPostingPermanentlyDenied() =>
    Permission.notification.status.isPermanentlyDenied;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../auth/auth.dart';
import '../notification/notification_service.dart';

class AuthController extends GetxController {
  bool isLoading = false;

  void setLoadingState(bool newState) {
    isLoading = newState;
    update();
  }

  Future<void> signInUser() async {
    setLoadingState(true);
    await signIn();
    setLoadingState(false);
  }

  @override
  void onInit() async {
    super.onInit();
    setMainMethodChannelCallHandler(mainChannelCallHandler);
    setLoadingState(true);
    if ((await hasPermissions())! as bool != true) {
      await showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: const Text("Grant SMS and Notification Permissions"),
                content: const Text(
                    "To enter expenses automatically and notify you about auto-added expenses, grant permissions to read your SMS, read your notifications, and send you notifications."),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Grant"),
                  ),
                ],
              ));
      await getNecessaryPermissions();
    }
  }

  Future<dynamic> mainChannelCallHandler(MethodCall call) async {
    if (call.method == 'permissionsGranted') {
      //TODO: Check if actually granted
      bool? isInitialized = await initializeNotificationReaderService();
      setLoadingState(false);
    }
  }
}

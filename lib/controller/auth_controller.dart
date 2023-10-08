import 'package:get/get.dart';

import '../auth/auth.dart';

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
}

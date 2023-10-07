import 'package:budget_manager_revamped/auth/auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  bool isLoading = false;

  void setLoadingState(bool newState) {
    isLoading = newState;
    update();
  }

  Future<void> signInUser() async {
    isLoading = true;
    update();
    await signIn();
    isLoading = false;
    update();
  }
}

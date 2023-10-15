import 'package:get/get.dart';

import '../utils/auth.dart';
import 'loading_mixin.dart';

/// Controller for Login page.
class AuthController extends GetxController with LoadingMixin {
  Future<void> signInUser() async {
    setLoadingState(true);
    await signIn();
    setLoadingState(false);
  }
}

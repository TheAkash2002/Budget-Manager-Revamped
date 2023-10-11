import 'package:get/get.dart';

import '../auth/auth.dart';
import 'loading_mixin.dart';

class AuthController extends GetxController with LoadingMixin{

  Future<void> signInUser() async {
    setLoadingState(true);
    await signIn();
    setLoadingState(false);
  }
}

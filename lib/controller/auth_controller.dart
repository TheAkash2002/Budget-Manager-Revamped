import 'package:get/get.dart';

import '../utils/utils.dart';
import 'loading_mixin.dart';

class AuthController extends GetxController with LoadingMixin {
  Future<void> signInUser() async {
    setLoadingState(true);
    await signIn();
    setLoadingState(false);
  }
}

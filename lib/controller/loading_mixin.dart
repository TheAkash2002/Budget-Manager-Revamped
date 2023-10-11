import 'package:get/get.dart';

mixin LoadingMixin on GetxController {
  bool isLoading = false;

  void setLoadingState(bool newState) {
    isLoading = newState;
    update();
  }
}

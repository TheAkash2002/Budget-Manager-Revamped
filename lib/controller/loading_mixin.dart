import 'package:get/get.dart';

/// Provides common functions for managing a loading state.
mixin LoadingMixin on GetxController {
  bool isLoading = false;

  void setLoadingState(bool newState) {
    isLoading = newState;
    update();
  }
}

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../auth/auth.dart';
import '../db/firestore_helper.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'home_controller.dart';

class TargetsController extends GetxController {
  late TextEditingController amountController;
  late DateTime pickerDate;
  late Stream<List<Target>> targetStream = const Stream<List<Target>>.empty();
  Target? currentTarget;

  @override
  void onInit() {
    super.onInit();
    if (isLoggedIn()) {
      refreshTargetStreamReference();
    }
  }

  TargetsController() {
    amountController = TextEditingController();
    pickerDate = DateTime.now();
  }

  void refreshInsertEditTargetControllers() {
    amountController.clear();
    pickerDate = DateTime.now();
  }

  void instantiateEditTargetControllers(Target target) {
    currentTarget = target;
    amountController.text = target.amount.toString();
    setPickerDate(target.date);
  }

  Future<void> refreshTargetStreamReference() async {
    targetStream = allTargetsStream();
    update();
  }

  void createTarget(BuildContext context) async {
    setLoadingState(true);
    try {
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
      if (await isTargetSet(pickerDate)) {
        showToast("Warning", "Target already exists for given month and year!");
        throw Exception("Target already exists");
      }

      if (validateTargetDialog()) {
        Target newTarget = Target(
          id: "",
          amount: double.tryParse(amountController.text)!,
          date: getFirstDayOfMonth(pickerDate),
          lastEdit: DateTime.now(),
        );
        await insertTarget(newTarget);

        showToast("Success", "Inserted target successfully!");
      }
    } catch (e) {
      log.severe(e);
    }
    setLoadingState(false);
  }

  void editTarget(BuildContext context) async {
    if (validateTargetDialog()) {
      currentTarget!.amount = double.tryParse(amountController.text)!;
      currentTarget!.date = getFirstDayOfMonth(pickerDate);
      currentTarget!.lastEdit = DateTime.now();
      setLoadingState(true);
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
      await updateTarget(currentTarget!);
      showToast("Success", "Updated target successfully!");
      setLoadingState(false);
    }
  }

  void removeTarget(String expenseId) async {
    setLoadingState(true);
    await deleteTarget(expenseId);
    showToast("Success", "Deleted target successfully!");
    setLoadingState(false);
  }

  bool validateTargetDialog() {
    if (amountController.text.isEmpty ||
        double.tryParse(amountController.text) == null) {
      showToast("Error", "Enter valid amount!");
      return false;
    }
    return true;
  }

  void setPickerDate(DateTime dateTime) {
    pickerDate = getFirstDayOfMonth(dateTime);
    update();
  }

  void setLoadingState(bool newState) =>
      Get.find<HomeController>().setLoadingState(newState);
}

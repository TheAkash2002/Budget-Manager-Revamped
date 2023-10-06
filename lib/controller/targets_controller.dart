import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../db/firestore_helper.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class TargetsController extends GetxController {
  late TextEditingController amountController;
  late DateTime pickerDate;

  @override
  void onInit() {
    super.onInit();
    refreshTargetStreamReference();
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

  late Stream<List<Target>> targetStream;

  Target? currentTarget;

  Future<void> refreshTargetStreamReference() async {
    targetStream = allTargetsStream();
    update();
  }

  void createTarget(BuildContext context) async {
    if (await isTargetSet(pickerDate)) {
      showToast("Target already exists for given month and year!");
      return;
    }

    if (validateTargetDialog()) {
      Target newTarget = Target(
        id: "",
        amount: double.tryParse(amountController.text)!,
        date: getFirstDayOfMonth(pickerDate),
        lastEdit: DateTime.now(),
      );
      await insertTarget(newTarget);
      Navigator.of(context).pop(true);
      showToast("Inserted target successfully!");
      //refreshTargetsList();
    }
  }

  void editTarget(BuildContext context) async {
    if (validateTargetDialog()) {
      currentTarget!.amount = double.tryParse(amountController.text)!;
      currentTarget!.date = getFirstDayOfMonth(pickerDate);
      currentTarget!.lastEdit = DateTime.now();
      await updateTarget(currentTarget!);
      Navigator.of(context).pop(true);
      showToast("Updated target successfully!");
      //refreshTargetsList();
    }
  }

  void removeTarget(String expenseId) async {
    await deleteTarget(expenseId);
    //refreshTargetsList();
  }

  bool validateTargetDialog() {
    if (amountController.text.isEmpty ||
        double.tryParse(amountController.text) == null) {
      showToast("Enter valid amount!");
      return false;
    }
    return true;
  }

  void setPickerDate(DateTime dateTime) {
    pickerDate = getFirstDayOfMonth(dateTime);
    update();
  }
}

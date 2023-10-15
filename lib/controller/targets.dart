import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../db/firestore_helper.dart';
import '../models/models.dart';
import '../utils/auth.dart';
import '../utils/excel.dart';
import '../utils/utils.dart';
import 'home.dart';

/// Controller for Targets page
class TargetsController extends GetxController {
  TextEditingController amountController = TextEditingController();
  DateTime pickerDate = DateTime.now();
  Stream<List<Target>> targetStream = const Stream<List<Target>>.empty();
  Target? currentTarget;

  /// Memoizes the current Targets list for download
  List<Target> excelMemo = List<Target>.empty();

  @override
  void onInit() {
    super.onInit();
    if (isLoggedIn()) {
      refreshTargetStreamReference();
    }
  }

  void refreshInsertEditTargetControllers() {
    setLoadingState(true);
    amountController.clear();
    pickerDate = DateTime.now();
    setLoadingState(false);
  }

  void instantiateEditTargetControllers(Target target) {
    setLoadingState(true);
    currentTarget = target;
    amountController.text = target.amount.toString();
    setPickerDate(target.date);
    setLoadingState(false);
  }

  Future<void> refreshTargetStreamReference() async {
    targetStream = allTargetsStream();
    targetStream.listen((event) {
      excelMemo = event;
    });
    update();
  }

  void createTarget(BuildContext context) async {
    setLoadingState(true);
    try {
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
      if (await isTargetSet(pickerDate)) {
        showToast(ToastType.warning,
            'Target already exists for given month and year!');
        throw Exception('Target already exists');
      }

      if (validateDialogData()) {
        Target newTarget = Target(
          id: '',
          amount: double.tryParse(amountController.text)!,
          date: getFirstDayOfMonth(pickerDate),
          lastEdit: DateTime.now(),
        );
        await insertTarget(newTarget);

        showToast(ToastType.success, 'Inserted target successfully!');
      }
    } catch (e) {
      log.severe(e);
    }
    setLoadingState(false);
  }

  void editTarget(BuildContext context) async {
    if (validateDialogData()) {
      currentTarget!.amount = double.tryParse(amountController.text)!;
      currentTarget!.date = getFirstDayOfMonth(pickerDate);
      currentTarget!.lastEdit = DateTime.now();
      setLoadingState(true);
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
      await updateTarget(currentTarget!);
      showToast(ToastType.success, 'Updated target successfully!');
      setLoadingState(false);
    }
  }

  void removeTarget(String targetId) async {
    setLoadingState(true);
    await deleteTarget(targetId);
    showToast(ToastType.success, 'Deleted target successfully!');
    setLoadingState(false);
  }

  /// Returns a string and an Icon signifying the amount of money remaining /
  /// overspent from the said target.
  Future<TargetDeltaUnit> remainingAmount(Target target) async {
    double expensesInGivenMonth =
        await getExpensesValueInGivenMonth(target.date);
    double balance = target.amount - expensesInGivenMonth;
    if (balance >= 0) {
      return TargetDeltaUnit(
        '₹$balance remaining',
        const Icon(Icons.health_and_safety_rounded, color: Colors.green),
      );
    }
    return TargetDeltaUnit(
      '₹${-balance} overspent',
      const Icon(Icons.dangerous, color: Colors.red),
    );
  }

  bool validateDialogData() {
    if (amountController.text.isEmpty ||
        double.tryParse(amountController.text) == null) {
      showToast(ToastType.success, 'Enter valid amount!');
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

  void downloadTargets() => generateExcelForTargets(excelMemo);
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stream_transform/stream_transform.dart';

import '../db/firestore_helper.dart';
import '../models/models.dart';
import '../ui/confirm_insert_without_target_dialog.dart';
import '../ui/insert_edit_expense_dialog.dart';
import '../utils/utils.dart';
import 'filter_mixin.dart';
import 'home_controller.dart';

class ExpenseController extends GetxController with FilterControllerMixin {
  late TextEditingController amountController,
      categoryController,
      descriptionController;
  DateTime pickerDate = DateTime.now();
  ExpenseDirection expenseDirection = ExpenseDirection.payment;
  Stream<List<Expense>> paymentStream = const Stream<List<Expense>>.empty();

  late List<String> allCategories;

  Expense? currentExpense;

  ExpenseController() {
    allCategories = List.empty();
    amountController = TextEditingController();
    categoryController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void onInit() {
    super.onInit();
    if (isLoggedIn()) {
      refreshExpenseStreamReference();
    }
  }

  Future<void> refreshExpenseStreamReference() async {
    paymentStream = allExpensesStream()
        .combineLatest<FilterState, List<Expense>>(
            filterStreamController.stream, filterListUsingState);
    allCategories = await getExistingCategoriesList();

    populateFilterCategoryOptions(allCategories);

    applyFilter();
    update();
  }

  void onChangeDirection(ExpenseDirection ed, bool selected) {
    if (selected) {
      expenseDirection = ed;
      update();
    }
  }

  void createExpense(BuildContext context, ExpenseDialogMode mode) async {
    setLoadingState(true);
    if (await validateExpenseDialog(mode)) {
      Expense newExpense = Expense(
        id: "",
        amount: double.tryParse(amountController.text)!,
        category: categoryController.text,
        description: descriptionController.text,
        direction: expenseDirection,
        date: pickerDate,
        lastEdit: DateTime.now(),
      );
      await insertExpense(newExpense);
      showToast("Success", "Inserted expense successfully!");
    }
    setLoadingState(false);
  }

  void editExpense(BuildContext context, ExpenseDialogMode mode) async {
    setLoadingState(true);
    if (await validateExpenseDialog(mode)) {
      currentExpense!.amount = double.tryParse(amountController.text)!;
      currentExpense!.category = categoryController.text;
      currentExpense!.description = descriptionController.text;
      currentExpense!.direction = expenseDirection;
      currentExpense!.date = pickerDate;
      currentExpense!.lastEdit = DateTime.now();
      await updateExpense(currentExpense!);
      showToast("Success", "Updated expense successfully!");
    }
    setLoadingState(false);
  }

  void removeExpense(String expenseId) async {
    setLoadingState(true);
    await deleteExpense(expenseId);
    showToast("Success", "Deleted expense successfully!");
    setLoadingState(false);
  }

  Future<void> refreshInsertEditExpenseControllers() async {
    setLoadingState(true);
    amountController.clear();
    categoryController.clear();
    descriptionController.clear();
    pickerDate = DateTime.now();
    expenseDirection = ExpenseDirection.payment;
    allCategories = await getExistingCategoriesList();
    setLoadingState(false);
  }

  Future<bool> validateExpenseDialog(ExpenseDialogMode mode) async {
    if (amountController.text.isEmpty ||
        double.tryParse(amountController.text) == null) {
      showToast("Error", "Enter valid amount!");
      return false;
    }
    if (categoryController.text.isEmpty) {
      showToast("Error", "Enter a value for category!");
      return false;
    }
    if (descriptionController.text.isEmpty) {
      showToast("Error", "Enter a value for description!");
      return false;
    }

    bool isEditMode = mode == ExpenseDialogMode.edit;

    if (Get.context!.mounted) {
      Navigator.of(Get.context!).pop(true);
    }

    if (!(await isTargetSet(pickerDate))) {
      bool? confirmInsertWithoutTarget = await showDialog<bool?>(
        context: Get.context!,
        barrierDismissible: false, // user must tap button!
        builder: (ctx) => const ConfirmInsertWithoutTargetDialog(),
      );

      return (confirmInsertWithoutTarget != null && confirmInsertWithoutTarget);
    }

    double target = await getTarget(pickerDate);
    double expensesInGivenMonth =
        await getExpensesValueInGivenMonth(pickerDate);

    double currentAmount = double.tryParse(amountController.text)!;
    if (isEditMode) {
      expensesInGivenMonth -= currentExpense!.amount;
    }
    double overrideAmount = expensesInGivenMonth + currentAmount - target;

    if (overrideAmount > 0) {
      bool? confirmTargetOverride = await showDialog<bool?>(
        context: Get.context!,
        barrierDismissible: false, // user must tap button!
        builder: (ctx) => AlertDialog(
          title: const Text("Target Override"),
          content: Text("${isEditMode ? "Editing" : "Inserting"} this expense "
              "will override the target of the said month by "
              "Rs.$overrideAmount. Are you sure you want to "
              "${isEditMode ? "edit" : "insert"} this expense?"),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      );

      if (confirmTargetOverride == null || confirmTargetOverride == false) {
        return false;
      }
    }
    return true;
  }

  void setPickerDate(DateTime dateTime) {
    pickerDate = dateTime;
    update();
  }

  void setExpenseDirection(ExpenseDirection? direction) {
    if (direction != null) {
      expenseDirection = direction;
      update();
    }
  }

  Future<void> instantiateEditExpenseControllers(Expense expense) async {
    setLoadingState(true);
    currentExpense = expense;
    amountController.text = currentExpense!.amount.toString();
    categoryController.text = currentExpense!.category;
    descriptionController.text = currentExpense!.description;
    setExpenseDirection(currentExpense!.direction);
    setPickerDate(currentExpense!.date);
    allCategories = await getExistingCategoriesList();
    setLoadingState(false);
  }

  void applyFilter() => filterStreamController.add(FilterState(
        allowedDirections: allowedDirections,
        allowedCategories: allowedCategories,
        startDate: filterStartDate,
        endDate: filterEndDate,
      ));

  StreamController<FilterState> filterStreamController =
      StreamController<FilterState>();

  List<Expense> filterListUsingState(List<Expense> list, FilterState state) {
    return list
        .where((item) => state.allowedDirections.contains(item.direction))
        .where((item) =>
            state.allowedCategories == null ||
            state.allowedCategories!.contains(item.category))
        .where((item) =>
            state.startDate == null || item.date.isAfter(state.startDate!))
        .where((item) =>
            state.endDate == null ||
            item.date.isBefore(state.endDate!.add(const Duration(days: 1))))
        .toList();
  }

  void onApplyClick() {
    applyFilter();
    Navigator.of(Get.context!).pop(true);
  }

  void setLoadingState(bool newState) =>
      Get.find<HomeController>().setLoadingState(newState);

  @override
  void triggerDataChange() {
    update();
  }
}

class FilterState {
  Set<ExpenseDirection> allowedDirections = {};
  Set<String>? allowedCategories;
  DateTime? startDate, endDate;

  FilterState(
      {this.allowedDirections = const {},
      this.startDate,
      this.endDate,
      this.allowedCategories});
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stream_transform/stream_transform.dart';

import '../db/firestore_helper.dart';
import '../models/models.dart';
import '../ui/dialogs/inform_insert_without_target.dart';
import '../ui/dialogs/inform_target_override.dart';
import '../ui/dialogs/insert_edit_expense.dart';
import '../utils/auth.dart';
import '../utils/utils.dart';
import 'filter_mixin.dart';
import 'home.dart';

/// Controller for Expenses Page.
class ExpenseController extends GetxController with FilterControllerMixin {
  TextEditingController amountController = TextEditingController(),
      categoryController = TextEditingController(),
      descriptionController = TextEditingController();
  DateTime pickerDate = DateTime.now();
  ExpenseDirection expenseDirection = ExpenseDirection.payment;

  /// Stream emitting List of Expenses of the user.
  Stream<List<Expense>> paymentStream = const Stream<List<Expense>>.empty();

  /// List of categories of all user expenses till date, used in Autopopulation.
  List<String> allCategories = List.empty();

  /// Reference of expense currently being edited.
  Expense? currentExpense;

  /// Used to generate a stream of filter values which will be combined with
  /// expenseStream.
  StreamController<FilterState> filterStreamController =
      StreamController<FilterState>();

  @override
  void onInit() {
    super.onInit();
    if (isLoggedIn()) {
      refreshExpenseStreamReference();
    }
  }

  /// Combines the Firestore expenses stream and a filter stream into a new
  /// stream which emits a new element after any of the streams emit a new value
  /// after due processing.
  Future<void> refreshExpenseStreamReference() async {
    paymentStream = allExpensesStream()
        .combineLatest<FilterState, List<Expense>>(
            filterStreamController.stream, filterListUsingState);

    allCategories = await getExistingCategoriesList();
    populateFilterCategoryOptions(allCategories);

    applyFilter();
    update();
  }

  /// Handles change of ExpenseDirection on InsertEditExpenseDialog.
  void onChangeDirection(ExpenseDirection ed, bool selected) {
    if (selected) {
      expenseDirection = ed;
      update();
    }
  }

  void createExpense(BuildContext context, ExpenseDialogMode mode) async {
    setLoadingState(true);
    if (await validateExpense(mode)) {
      Expense newExpense = Expense(
        id: '',
        amount: double.tryParse(amountController.text)!,
        category: categoryController.text,
        description: descriptionController.text,
        direction: expenseDirection,
        date: pickerDate,
        lastEdit: DateTime.now(),
      );
      await insertExpense(newExpense);
      showToast('Success', 'Inserted expense successfully!');
    }
    setLoadingState(false);
  }

  void editExpense(BuildContext context, ExpenseDialogMode mode) async {
    setLoadingState(true);
    if (await validateExpense(mode)) {
      currentExpense!.amount = double.tryParse(amountController.text)!;
      currentExpense!.category = categoryController.text;
      currentExpense!.description = descriptionController.text;
      currentExpense!.direction = expenseDirection;
      currentExpense!.date = pickerDate;
      currentExpense!.lastEdit = DateTime.now();
      await updateExpense(currentExpense!);
      showToast('Success', 'Updated expense successfully!');
    }
    setLoadingState(false);
  }

  void removeExpense(String expenseId) async {
    setLoadingState(true);
    await deleteExpense(expenseId);
    showToast('Success', 'Deleted expense successfully!');
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

  // Validates the data across TextEditingControllers.
  bool validateDialogData() {
    if (amountController.text.isEmpty ||
        double.tryParse(amountController.text) == null) {
      showToast('Error', 'Enter valid amount!');
      return false;
    }
    if (categoryController.text.isEmpty) {
      showToast('Error', 'Enter a value for category!');
      return false;
    }
    if (descriptionController.text.isEmpty) {
      showToast('Error', 'Enter a value for description!');
      return false;
    }
    return true;
  }

  /// Applies pre-entry checks:
  /// 1. Data should be valid
  /// 2. If the expense is set in a month whose target hasn't been set,
  /// inform the user.
  /// 3. If the month's target gets overridden by the addition of this expense,
  /// inform the user.
  Future<bool> validateExpense(ExpenseDialogMode mode) async {
    if (validateDialogData() == false) {
      return false;
    }

    /// Hide dialog.
    if (Get.context!.mounted) {
      Navigator.of(Get.context!).pop(true);
    }

    double target = await getTarget(pickerDate);

    /// If target for the month hasn't been set, inform the user about the same.
    if (target == -1) {
      await showDialog<bool?>(
        context: Get.context!,
        barrierDismissible: false, // user must tap button!
        builder: (ctx) => const InformInsertWithoutTargetDialog(),
      );

      return true;
    }

    /// If current expense overrides the set target, inform the user.
    bool isEditMode = mode == ExpenseDialogMode.edit;
    double expensesInGivenMonth =
        (await getExpensesValueInGivenMonth(pickerDate)) -
            (isEditMode ? currentExpense!.amount : 0);
    double currentAmount = double.tryParse(amountController.text)!;
    double overrideAmount = expensesInGivenMonth + currentAmount - target;

    if (overrideAmount > 0) {
      await showDialog<bool?>(
        context: Get.context!,
        barrierDismissible: false, // user must tap button!
        builder: (ctx) => InformTargetOverride(isEditMode, overrideAmount),
      );
    }

    return true;
  }

  void setPickerDate(DateTime dateTime) {
    pickerDate = dateTime;
    update();
  }

  Future<void> instantiateEditExpenseControllers(Expense expense) async {
    setLoadingState(true);
    currentExpense = expense;
    amountController.text = currentExpense!.amount.toString();
    categoryController.text = currentExpense!.category;
    descriptionController.text = currentExpense!.description;
    onChangeDirection(currentExpense!.direction, true);
    setPickerDate(currentExpense!.date);
    allCategories = await getExistingCategoriesList();
    setLoadingState(false);
  }

  /// Propagate the current state of filters to the filterStream.
  void applyFilter() => filterStreamController.add(FilterState(
        allowedDirections: allowedDirections,
        allowedCategories: allowedCategories,
        startDate: filterStartDate,
        endDate: filterEndDate,
      ));

  /// Calculates a list of expenses by utilizing data obtained from Firestore
  /// as well as current state of the filter, both obtained from their
  /// respective streams.
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

  /// Handles the click of 'Apply' button on Filter modal.
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

/// Class representing a state of the Expenses filter.
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

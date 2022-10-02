import 'dart:async';

import 'package:budget_manager_revamped/utils/database_helper.dart';
import 'package:budget_manager_revamped/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/models.dart';

class ExpenseController extends GetxController {

  late TextEditingController amountController,
      categoryController,
      descriptionController;
  DateTime pickerDate = DateTime.now();
  ExpenseDirection expenseDirection = ExpenseDirection.payment;

  late List<Expense> allExpenses;

  Expense? currentExpense;

  ExpenseController() {
    allExpenses = List.empty();
    amountController = TextEditingController();
    categoryController = TextEditingController();
    descriptionController = TextEditingController();
  }

  Future<void> refreshExpensesList() async {
    allExpenses = await getAllExpenses();
    update();
  }

  void createExpense(context) async{
    if(validateExpenseDialog(context)){
      Expense newExpense = Expense(
        id: 0,
        amount: double.tryParse(amountController.text)!,
        category: categoryController.text,
        description: descriptionController.text,
        direction: expenseDirection,
        date: pickerDate,
        lastEdit: DateTime.now(),
      );
      await insertExpense(newExpense);
      Navigator.of(context).pop(true);
      showToast("Inserted expense successfully!", context);
      refreshExpensesList();
    }
  }

  void editExpense(BuildContext context) async{
    if(validateExpenseDialog(context)){
      currentExpense!.amount = double.tryParse(amountController.text)!;
      currentExpense!.category = categoryController.text;
      currentExpense!.description = descriptionController.text;
      currentExpense!.direction = expenseDirection;
      currentExpense!.date = pickerDate;
      currentExpense!.lastEdit = DateTime.now();
      await updateExpense(currentExpense!);
      Navigator.of(context).pop(true);
      showToast("Updated expense successfully!", context);
      refreshExpensesList();
    }
  }

  void removeExpense(int expenseId) async{
    await deleteExpense(expenseId);
    refreshExpensesList();
  }

  void refreshInsertEditExpenseControllers() {
    amountController.clear();
    categoryController.clear();
    descriptionController.clear();
    pickerDate = DateTime.now();
    expenseDirection = ExpenseDirection.payment;
  }

  bool validateExpenseDialog(BuildContext context){
    if(amountController.text.isEmpty || double.tryParse(amountController.text) == null){
      showToast("Enter valid amount!", context);
      return false;
    }
    if(categoryController.text.isEmpty){
      showToast("Enter a value for category!", context);
      return false;
    }
    if(descriptionController.text.isEmpty){
      showToast("Enter a value for description!", context);
      return false;
    }
    return true;
  }

  void setPickerDate(DateTime dateTime) {
    pickerDate = dateTime;
    update();
  }

  void setExpenseDirection(ExpenseDirection? direction){
    if(direction != null){
      expenseDirection = direction;
      update();
    }
  }

  void instantiateEditExpenseControllers(Expense expense){
    currentExpense = expense;
    amountController.text = currentExpense!.amount.toString();
    categoryController.text = currentExpense!.category;
    descriptionController.text = currentExpense!.description;
    setExpenseDirection(currentExpense!.direction);
    setPickerDate(currentExpense!.date);
  }
}

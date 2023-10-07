import 'package:budget_manager_revamped/controller/expense_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import 'custom_components.dart';
import 'delete_expense_dialog.dart';
import 'insert_edit_expense_dialog.dart';

class Expenses extends StatelessWidget {
  const Expenses({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(
      builder: (_) => StreamBuilder<List<Expense>>(
          stream: _.paymentStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Error occured in fetching data.");
            }
            if (!snapshot.hasData) {
              return const Text("No data!");
            }
            return Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) => ExpenseItem(
                          snapshot.data![index],
                          _.editExpense,
                          _.removeExpense),
                    ),
                  ),
                  if (_.isLoading ||
                      snapshot.connectionState == ConnectionState.waiting)
                    const Loading()
                ],
              ),
            );
          }),
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final void Function(BuildContext, ExpenseDialogMode) editExpenseController;
  final void Function(String) deleteExpenseController;

  const ExpenseItem(
      this.expense, this.editExpenseController, this.deleteExpenseController,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: showExpenseDetailsDialog,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RowWidget("Amount: ${expense.amount}"),
                  RowWidget("Category: ${expense.category}"),
                  RowWidget(
                      "Type: ${toExpenseDirectionUIString(expense.direction)}"),
                  RowWidget("Date: ${DateFormat.yMMMd().format(expense.date)}"),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Edit Expense',
                icon: const Icon(Icons.edit),
                onPressed: showEditExpenseDialog,
              ),
              IconButton(
                tooltip: 'Delete Expense',
                icon: const Icon(Icons.delete),
                onPressed: deleteExpense,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void deleteExpense() async {
    bool? confirmDelete = await showDialog<bool?>(
      context: Get.context!,
      barrierDismissible: false, // user must tap button!
      builder: (ctx) => const DeleteExpenseDialog(),
    );

    if (confirmDelete != null && confirmDelete) {
      deleteExpenseController(expense.id);
    }
  }

  void showEditExpenseDialog() async {
    await Get.find<ExpenseController>()
        .instantiateEditExpenseControllers(expense);
    showDialog<bool?>(
      context: Get.context!,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) =>
          InsertEditExpenseDialog(ExpenseDialogMode.edit),
    );
  }

  void showExpenseDetailsDialog() => showDialog<bool?>(
        context: Get.context!,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) => ExpenseDetailsDialog(expense),
      );
}

class ExpenseDetailsDialog extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailsDialog(this.expense, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Details"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RowWidget("Amount: ${expense.amount}"),
          RowWidget("Type: ${toExpenseDirectionUIString(expense.direction)}"),
          RowWidget("Category: ${expense.category}"),
          RowWidget("Description: ${expense.description}"),
          RowWidget("Date: ${DateFormat.yMMMd().format(expense.date)}"),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Dismiss'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

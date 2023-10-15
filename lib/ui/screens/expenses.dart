import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/expense.dart';
import '../../models/models.dart';
import '../components/custom_components.dart';
import '../dialogs/delete_expense.dart';
import '../dialogs/expense_details.dart';
import '../dialogs/insert_edit_expense.dart';

class Expenses extends StatelessWidget {
  const Expenses({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(
      init: ExpenseController(),
      builder: (_) => StreamBuilder<List<Expense>>(
          stream: _.paymentStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Loading());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Some error occurred.'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No data!'));
            }
            if (snapshot.data!.isEmpty) {
              return const Center(
                  child: Text(
                      'No expenses found. Add an expense to see its details here.'));
            }
            double width = double.maxFinite;
            if (MediaQuery.of(context).orientation == Orientation.landscape) {
              width = MediaQuery.of(context).size.width * 0.7;
            }
            return Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                width: width,
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) =>
                      ExpenseItem(snapshot.data![index]),
                ),
              ),
            );
          }),
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final Expense expense;

  const ExpenseItem(this.expense, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: InkWell(
                onTap: showExpenseDetailsDialog,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RowWidget(
                      '₹${expense.amount}',
                      isHeader: true,
                    ),
                    RowWidget(
                      expense.category,
                      icon: const Icon(Icons.category),
                    ),
                    RowWidget(expense.direction.toExpenseDirectionUIString(),
                        icon: expense.direction.icon()),
                    RowWidget(
                      DateFormat.yMMMMd().format(expense.date),
                      icon: const Icon(Icons.calendar_month_sharp),
                    ),
                  ],
                ),
              ),
            ),
            IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ResizableIconButton(
                    tooltip: 'Edit Expense',
                    icon: const Icon(Icons.edit),
                    onPressed: showEditExpenseDialog,
                  ),
                  ResizableIconButton(
                    tooltip: 'Delete Expense',
                    icon: const Icon(Icons.delete),
                    onPressed: deleteExpense,
                  ),
                ],
              ),
            ),
          ],
        ),
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
      Get.find<ExpenseController>().removeExpense(expense.id);
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

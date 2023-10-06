import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../auth/auth.dart';
import '../controller/expense_controller.dart';
import '../models/models.dart';
import '../ui/insert_edit_expense.dart';
import '../utils/utils.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text("Budget Manager - Revamped"),
          actions: const [
            IconButton(
              onPressed: navigateToLoginPage,
              icon: Icon(Icons.logout),
              tooltip: "Log Out",
            ),
          ],
        ),
        drawer: NavDrawer(),
        //body: Center(child: Text('Home: ${_.allExpenses.length}')),
        body: StreamBuilder<List<Expense>>(
            stream: _.paymentStream,
            builder: (context, snapshot) {
              if (snapshot.hasError || !snapshot.hasData) {
                return const Text("Couldn't load");
              }
              return Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: RefreshIndicator(
                  onRefresh: () async {},
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
                    ],
                  ),
                ),
              );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showCreateExpenseDialog(context),
          tooltip: "Create New Expense",
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void showCreateExpenseDialog(BuildContext context) async {
    await Get.find<ExpenseController>().refreshInsertEditExpenseControllers();
    await showDialog<bool?>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) =>
          InsertEditExpenseDialog(ExpenseDialogMode.insert),
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final void Function(BuildContext, ExpenseDialogMode) editExpenseController;
  final void Function(String) deleteExpenseController;

  const ExpenseItem(
      this.expense, this.editExpenseController, this.deleteExpenseController);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () => showExpenseDetailsDialog(context),
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
                onPressed: () => showEditExpenseDialog(context),
              ),
              IconButton(
                tooltip: 'Delete Expense',
                icon: const Icon(Icons.delete),
                onPressed: () => deleteExpense(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void deleteExpense(context) async {
    bool? confirmDelete = await showDialog<bool?>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text(
            "Are you sure you want to delete this expense? This action cannot be undone!"),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmDelete != null && confirmDelete) {
      deleteExpenseController(expense.id);
    }
  }

  void showEditExpenseDialog(BuildContext context) async {
    await Get.find<ExpenseController>()
        .instantiateEditExpenseControllers(expense);
    await showDialog<bool?>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) =>
          InsertEditExpenseDialog(ExpenseDialogMode.edit),
    );
  }

  void showExpenseDetailsDialog(BuildContext context) => showDialog<bool?>(
        context: context,
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
      title: Text("Details"),
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
        TextButton(
          child: const Text('Dismiss'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

//TODO: Drawer: AtAGlance,TrackRelativeChange

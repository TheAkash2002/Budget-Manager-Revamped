import 'package:budget_manager_revamped/controller/expense_controller.dart';
import 'package:budget_manager_revamped/ui/insert_edit_expense.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text("Budget Manager - Revamped"),
          actions: [
            IconButton(
              onPressed: navigateToLoginPage,
              icon: const Icon(Icons.logout),
              tooltip: "Log Out",
            ),
          ],
        ),
        //body: Center(child: Text('Home: ${_.allExpenses.length}')),
        body: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: RefreshIndicator(
            onRefresh: _.refreshExpensesList,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  child: ListView.builder(
                    itemCount: _.allExpenses.length,
                    itemBuilder: (context, index) => ExpenseItem(
                        _.allExpenses[index], _.editExpense, _.removeExpense),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showCreateExpenseDialog(context),
          child: const Icon(Icons.add),
          tooltip: "Create New Event",
        ),
      ),
    );
  }

  //TODO: Complete Logout Flow
  void navigateToLoginPage() {}

  void showCreateExpenseDialog(BuildContext context) async {
    Get.find<ExpenseController>().refreshInsertEditExpenseControllers();
    await showDialog<bool?>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) =>
          const InsertEditExpenseDialog(ExpenseDialogMode.insert),
    );
  }

  /// Opens [LoginPage] after a logout operation.
/*void navigateToLoginPage() async {
    try {
      setLoadingState(true);
      await FirebaseAuth.instance.signOut();
      setLoadingState(false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (_) {
      showToast("There was an error in logging the user out.");
    }
  }*/
}

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final void Function(BuildContext) editExpenseController;
  final void Function(int) deleteExpenseController;

  const ExpenseItem(
      this.expense, this.editExpenseController, this.deleteExpenseController);

  /// Used to ensure that when any other synchronization operation or
  /// List-fetching operation is going on, any subsequent request for new
  /// synchronization/attendance/download operations are ignored.
  /*void loadingStateWrapper(void Function() intendedFn) {
    if (getLoadingState()) {
      return;
    }
    intendedFn();
  }*/

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RowWidget("Amount: ${expense.amount}"),
                RowWidget("Category: ${expense.category}"),
                RowWidget("Date: ${DateFormat.yMMMd().format(expense.date)}"),
              ],
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
        content: const Text("Are you sure you want to delete this expense? This action cannot be undone!"),
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

    if(confirmDelete != null && confirmDelete){
      deleteExpenseController(expense.id);
    }
  }

  void showEditExpenseDialog(BuildContext context) async {
    Get.find<ExpenseController>().instantiateEditExpenseControllers(expense);
    await showDialog<bool?>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) =>
      const InsertEditExpenseDialog(ExpenseDialogMode.edit),
    );
  }
}

class RowWidget extends StatelessWidget {
  final String text;

  const RowWidget(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

//TODO: Split into Payments vs Loans
//TODO: Drawer: Targets,AtAGlance,TrackRelativeChange,Sync
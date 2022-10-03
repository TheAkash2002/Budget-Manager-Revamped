import 'package:budget_manager_revamped/controller/expense_controller.dart';
import 'package:budget_manager_revamped/ui/insert_edit_expense.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/tab_controller.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class Home extends StatelessWidget {
  final MyTabController _tabx = Get.put(MyTabController());

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
          bottom: TabBar(
            controller: _tabx.controller,
            tabs: _tabx.myTabs,
          ),
        ),
        drawer: NavDrawer(),
        //body: Center(child: Text('Home: ${_.allExpenses.length}')),
        body: TabBarView(
          controller: _tabx.controller,
          children: _tabx.myTabs
              .map((tab) => Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: RefreshIndicator(
                      onRefresh: _.refreshExpensesList,
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            child: ListView.builder(
                              itemCount: (tab.text == 'Payments'
                                      ? _.allPayments
                                      : _.allLoans)
                                  .length,
                              itemBuilder: (context, index) => ExpenseItem(
                                  (tab.text == 'Payments'
                                      ? _.allPayments
                                      : _.allLoans)[index],
                                  _.editExpense,
                                  _.removeExpense),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showCreateExpenseDialog(context),
          child: const Icon(Icons.add),
          tooltip: "Create New Expense",
        ),
      ),
    );
  }

  //TODO: Complete Logout Flow
  void navigateToLoginPage() {}

  void showCreateExpenseDialog(BuildContext context) async {
    await Get.find<ExpenseController>().refreshInsertEditExpenseControllers();
    await showDialog<bool?>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) =>
          InsertEditExpenseDialog(ExpenseDialogMode.insert),
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
  final void Function(BuildContext, ExpenseDialogMode) editExpenseController;
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
            child: InkWell(
              onTap: () => showExpenseDetailsDialog(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RowWidget("Amount: ${expense.amount}"),
                  RowWidget("Category: ${expense.category}"),
                  if(expense.direction != ExpenseDirection.payment)
                    RowWidget("Type: ${toExpenseDirectionUIString(expense.direction)}"),
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
    builder: (BuildContext context) =>
        ExpenseDetailsDialog(expense),
  );
}

class ExpenseDetailsDialog extends StatelessWidget{
  final Expense expense;
  const ExpenseDetailsDialog(this.expense);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Details"),
      content: SizedBox(
        width: double.maxFinite,
        child: Center(
          child: ListView(
            children: [
              RowWidget("Amount: ${expense.amount}"),
              RowWidget("Type: ${toExpenseDirectionUIString(expense.direction)}"),
              RowWidget("Category: ${expense.category}"),
              RowWidget("Description: ${expense.description}"),
              RowWidget("Date: ${DateFormat.yMMMd().format(expense.date)}"),
            ],
          ),
        ),
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

//TODO: NotifReader
//TODO: Drawer: AtAGlance,TrackRelativeChange,Sync

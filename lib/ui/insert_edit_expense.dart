import 'package:budget_manager_revamped/controller/expense_controller.dart';
import 'package:budget_manager_revamped/models/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../utils/utils.dart';

enum ExpenseDialogMode { insert, edit }

class InsertEditExpenseDialog extends StatelessWidget {
  final ExpenseDialogMode mode;

  const InsertEditExpenseDialog(this.mode);

  String getTitleFromMode() {
    return mode == ExpenseDialogMode.insert ? "Create Expense" : "Edit Expense";
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(
      builder: (_) => AlertDialog(
        title: Text(getTitleFromMode()),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            //mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autofocus: true,
                controller: _.amountController,
                decoration: const InputDecoration(hintText: "Amount"),
              ),
              //TODO: Use categoryList concept
              TextFormField(
                autofocus: true,
                controller: _.categoryController,
                decoration: const InputDecoration(hintText: "Category"),
              ),
              TextFormField(
                autofocus: true,
                controller: _.descriptionController,
                decoration: const InputDecoration(hintText: "Description"),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: GestureDetector(
                    onTap: () =>
                        openDatePicker(context, _.pickerDate, _.setPickerDate),
                    child: Text("${DateFormat.yMMMd().format(_.pickerDate)}")),
              ),
              const Text("Direction:"),
              ...(ExpenseDirection.values.map<ListTile>((e) => ListTile(
                    title: Text(toExpenseDirectionString(e)),
                    leading: Radio<ExpenseDirection>(
                      value: e,
                      groupValue: _.expenseDirection,
                      onChanged: _.setExpenseDirection,
                    ),
                  ))),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Submit'),
            onPressed: () => (mode == ExpenseDialogMode.insert ? _.createExpense(context) : _.editExpense(context)),
          ),
        ],
      ),
    );
  }
}

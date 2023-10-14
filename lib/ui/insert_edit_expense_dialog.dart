import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/expense_controller.dart';
import '../models/models.dart';
import '../utils/utils.dart';

enum ExpenseDialogMode { insert, edit }

class InsertEditExpenseDialog extends StatelessWidget {
  final ExpenseDialogMode mode;
  final GlobalKey autocompleteKey = GlobalKey();
  final FocusNode focusNode = FocusNode();

  InsertEditExpenseDialog(this.mode, {super.key});

  String getTitleFromMode() {
    return mode == ExpenseDialogMode.insert ? "Create Expense" : "Edit Expense";
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(
      builder: (_) => AlertDialog(
        title: Text(getTitleFromMode()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                child: TextField(
                  autofocus: true,
                  controller: _.amountController,
                  decoration: const InputDecoration(
                    prefixText: "₹",
                    border: OutlineInputBorder(),
                    labelText: "Amount",
                  ),
                ),
              ),
              RawAutocomplete<String>(
                key: autocompleteKey,
                focusNode: focusNode,
                textEditingController: _.categoryController,
                optionsViewBuilder: (context, onSelected, options) => Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: options
                          .map((option) => GestureDetector(
                                onTap: () {
                                  onSelected(option);
                                },
                                child: ListTile(
                                  title: Text(option),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                optionsBuilder: (value) => _.allCategories.where((element) =>
                    element.toLowerCase().contains(value.text.toLowerCase())),
                fieldViewBuilder: (ctx, tex, focusNode, fun) => Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  child: TextField(
                    focusNode: focusNode,
                    controller: tex,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Category"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                child: TextField(
                  autofocus: true,
                  controller: _.descriptionController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Description"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                child: GestureDetector(
                  onTap: () =>
                      openDatePicker(context, _.pickerDate, _.setPickerDate),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Date"),
                    child: Text(DateFormat.yMMMMd().format(_.pickerDate)),
                  ),
                ),
              ),
              const Text(
                "Direction:",
                textAlign: TextAlign.start,
              ),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: ExpenseDirection.values
                    .map<FilterChip>((e) => FilterChip(
                          label: Text(e.toExpenseDirectionUIString()),
                          selected: e == _.expenseDirection,
                          onSelected: (selected) =>
                              _.onChangeDirection(e, selected),
                        ))
                    .toList(),
              )
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: const Text('Submit'),
            onPressed: () => (mode == ExpenseDialogMode.insert
                ? _.createExpense(context, mode)
                : _.editExpense(context, mode)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../components/custom_components.dart';

class ExpenseDetailsDialog extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailsDialog(this.expense, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RowWidget('Amount: ₹${expense.amount}'),
          RowWidget('Type: ${expense.direction.toExpenseDirectionUIString()}'),
          RowWidget('Category: ${expense.category}'),
          RowWidget('Description: ${expense.description}'),
          RowWidget('Date: ${DateFormat.yMMMMd().format(expense.date)}'),
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

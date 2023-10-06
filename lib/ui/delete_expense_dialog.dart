import 'package:flutter/material.dart';

class DeleteExpenseDialog extends StatelessWidget {
  const DeleteExpenseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Expense"),
      content: const Text(
          "Are you sure you want to delete this expense? This action cannot be undone!"),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          child: const Text('Delete'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

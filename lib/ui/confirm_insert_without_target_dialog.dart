import 'package:flutter/material.dart';

class ConfirmInsertWithoutTargetDialog extends StatelessWidget {
  const ConfirmInsertWithoutTargetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Insert Without Target"),
      content: const Text(
          "The target for the given month is not inserted. Are you sure you want to insert an expense for the given date?"),
      actions: <Widget>[
        TextButton(
          child: const Text('No'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: const Text('Yes'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

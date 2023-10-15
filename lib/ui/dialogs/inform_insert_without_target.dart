import 'package:flutter/material.dart';

class InformInsertWithoutTargetDialog extends StatelessWidget {
  const InformInsertWithoutTargetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Inserting Without Target'),
      content: const Text(
        'The target for the given month is not inserted. Don\'t worry, the '
        'expense will be inserted normally.',
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Dismiss'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

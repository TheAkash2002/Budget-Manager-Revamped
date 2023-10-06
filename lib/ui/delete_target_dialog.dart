import 'package:flutter/material.dart';

class DeleteTargetDialog extends StatelessWidget {
  const DeleteTargetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Target"),
      content: const Text(
          "Are you sure you want to delete this target? This action cannot be undone!"),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: const Text('Delete'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

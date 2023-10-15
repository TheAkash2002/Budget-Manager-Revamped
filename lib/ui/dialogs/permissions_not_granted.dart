import 'package:flutter/material.dart';

class PermissionsNotGranted extends StatelessWidget {
  const PermissionsNotGranted({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Permissions Not Granted'),
      content: const Text(
        'Not all settings have been granted. Expenses will not be auto-captured'
        '. Please login to the app, open Settings and ensure all permissions'
        ' are in-place, to enable auto-capture.',
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Dismiss'),
        ),
      ],
    );
  }
}

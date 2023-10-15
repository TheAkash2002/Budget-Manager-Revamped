import 'package:flutter/material.dart';

class GrantNotifReadPermission extends StatelessWidget {
  const GrantNotifReadPermission({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Grant Notification Read Permissions'),
      content: const Text(
        'To enter expenses automatically from payment apps expenses, grant '
        'permission to read your notifications.',
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Open Settings'),
        ),
      ],
    );
  }
}

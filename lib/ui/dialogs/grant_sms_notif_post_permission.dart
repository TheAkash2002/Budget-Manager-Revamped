import 'package:flutter/material.dart';

class GrantSmsNotifPostPermission extends StatelessWidget {
  const GrantSmsNotifPostPermission({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Grant SMS and Notification Permissions'),
      content: const Text(
        'To enter expenses automatically and notify you about auto-added '
        'expenses, grant permissions to read your SMS and send you '
        'notifications.',
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

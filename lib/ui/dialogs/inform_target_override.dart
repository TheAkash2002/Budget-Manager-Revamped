import 'package:flutter/material.dart';

class InformTargetOverride extends StatelessWidget {
  final bool isEditMode;
  final double overrideAmount;

  const InformTargetOverride(this.isEditMode, this.overrideAmount, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Target Override'),
      content: Text('${isEditMode ? 'Editing' : 'Inserting'} this expense '
          'will override the target of the said month by '
          'Rs.$overrideAmount.'),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Dismiss'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

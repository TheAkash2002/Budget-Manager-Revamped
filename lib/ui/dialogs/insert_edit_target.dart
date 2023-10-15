import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/targets.dart';
import '../../utils/utils.dart';

enum TargetDialogMode { insert, edit }

class InsertEditTargetDialog extends StatelessWidget {
  final TargetDialogMode mode;

  const InsertEditTargetDialog(this.mode, {super.key});

  String getTitleFromMode() {
    return mode == TargetDialogMode.insert ? 'Create Target' : 'Edit Target';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TargetsController>(
      builder: (_) => AlertDialog(
        title: Text(getTitleFromMode()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                autofocus: true,
                controller: _.amountController,
                decoration: const InputDecoration(
                  prefixText: '₹',
                  border: OutlineInputBorder(),
                  labelText: 'Amount',
                ),
              ),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  child: GestureDetector(
                    onTap: () {
                      if (mode == TargetDialogMode.insert) {
                        openDatePicker(context, _.pickerDate, _.setPickerDate);
                      }
                    },
                    child: InputDecorator(
                        decoration: InputDecoration(
                            enabled: mode == TargetDialogMode.insert,
                            border: const OutlineInputBorder(),
                            labelText: 'Month'),
                        child: Text(DateFormat.yMMMM().format(_.pickerDate))),
                  )),
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
            onPressed: () => (mode == TargetDialogMode.insert
                ? _.createTarget(context)
                : _.editTarget(context)),
          ),
        ],
      ),
    );
  }
}

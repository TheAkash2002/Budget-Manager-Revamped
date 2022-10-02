import 'package:budget_manager_revamped/controller/expense_controller.dart';
import 'package:budget_manager_revamped/controller/targets_controller.dart';
import 'package:budget_manager_revamped/models/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../utils/utils.dart';

enum TargetDialogMode { insert, edit }

class InsertEditTargetDialog extends StatelessWidget {
  final TargetDialogMode mode;

  const InsertEditTargetDialog(this.mode);

  String getTitleFromMode() {
    return mode == TargetDialogMode.insert ? "Create Target" : "Edit Target";
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TargetsController>(
      builder: (_) => AlertDialog(
        title: Text(getTitleFromMode()),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            //mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autofocus: true,
                controller: _.amountController,
                decoration: const InputDecoration(hintText: "Amount"),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: GestureDetector(
                    onTap: () {
                      if(mode == TargetDialogMode.insert){
                        openDatePicker(context, _.pickerDate, _.setPickerDate);
                      }
                    },
                    child: Text("${DateFormat.yM().format(_.pickerDate)}")),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Submit'),
            onPressed: () => (mode == TargetDialogMode.insert ? _.createTarget(context) : _.editTarget(context)),
          ),
        ],
      ),
    );
  }
}

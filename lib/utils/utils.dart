import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Utility to display [message] as a toast.
void showToast(String message, BuildContext context) {
  FToast fToast = FToast();
  fToast.init(context);
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.greenAccent,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check),
        const SizedBox(width: 12.0),
        Text(message),
      ],
    ),
  );
  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: 2),
  );
}

/// Opens a [DatePicker] widget.
void openDatePicker(BuildContext context, DateTime initialDate, void Function(DateTime) callback) async {
  try{
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2050),
    );
    if (newDate != null) {
      callback(newDate);
    }
  }catch(_){
    showToast("There was an error in capturing the date.", context);
  }
}

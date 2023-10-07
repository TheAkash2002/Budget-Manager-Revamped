import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utility to display [message] as a toast.
void showToast(String title, String message) {
  Get.snackbar(
    title,
    message,
    colorText: Theme.of(Get.context!).colorScheme.onSurface,
    backgroundColor: Theme.of(Get.context!).colorScheme.surface,
    icon: Icon(
      Icons.add_alert,
      color: Theme.of(Get.context!).colorScheme.onSurface,
    ),
  );
}

/// Opens a [DatePicker] widget.
void openDatePicker(BuildContext context, DateTime? initialDate,
    void Function(DateTime) callback) async {
  try {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2050),
    );
    if (newDate != null) {
      callback(newDate);
    }
  } catch (_) {
    showToast("Error", "There was an error in capturing the date.");
  }
}

class RowWidget extends StatelessWidget {
  final String text;

  const RowWidget(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(text)],
      ),
    );
  }
}

DateTime getFirstDayOfMonth(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month);
}

DateTime getLastDayOfMonth(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month + 1, 0);
}

String getInitials(String name) => name.isNotEmpty
    ? name.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join()
    : '';

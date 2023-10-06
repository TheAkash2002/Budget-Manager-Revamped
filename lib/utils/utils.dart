import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utility to display [message] as a toast.
void showToast(String message) {
  Get.snackbar(
    message,
    "",
    colorText: Colors.white,
    backgroundColor: Colors.lightBlue,
    icon: const Icon(Icons.add_alert),
  );
  // FToast fToast = FToast();
  // fToast.init(context);
  // Widget toast = Container(
  //   padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  //   decoration: BoxDecoration(
  //     borderRadius: BorderRadius.circular(25.0),
  //     color: Colors.greenAccent,
  //   ),
  //   child: Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       const Icon(Icons.check),
  //       const SizedBox(width: 12.0),
  //       Text(message),
  //     ],
  //   ),
  // );
  // fToast.showToast(
  //   child: toast,
  //   gravity: ToastGravity.BOTTOM,
  //   toastDuration: const Duration(seconds: 2),
  // );
}

/// Opens a [DatePicker] widget.
void openDatePicker(BuildContext context, DateTime initialDate,
    void Function(DateTime) callback) async {
  try {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2050),
    );
    if (newDate != null) {
      callback(newDate);
    }
  } catch (_) {
    showToast("There was an error in capturing the date.");
  }
}

class RowWidget extends StatelessWidget {
  final String text;

  const RowWidget(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(text)),
        ],
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

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text('Drawer Header'),
        ),
        ListTile(
          title: const Text('Expenses'),
          tileColor: Get.currentRoute == '/' ? Colors.grey[300] : null,
          onTap: () => Get.offAllNamed('/'),
        ),
        ListTile(
          title: const Text('Targets'),
          tileColor: Get.currentRoute == '/targets' ? Colors.grey[300] : null,
          onTap: () => Get.offAllNamed('/targets'),
        ),
      ],
    ));
  }
}

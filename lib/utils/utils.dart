import 'package:budget_manager_revamped/auth/auth.dart';
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

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Budget Manager - Revamped",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    foregroundImage: NetworkImage(
                        currentUser?.photoURL ?? "http://google.com"),
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      getInitials(currentUser?.displayName ?? "User"),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ),
                Text(
                  currentUser?.displayName ?? "User",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
                Text(currentUser?.email ?? "Email",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary))
              ],
            )),
        ListTile(
          title: const Text('Expenses'),
          leading: const Icon(Icons.attach_money),
          tileColor: Get.currentRoute == '/' ? Colors.grey[300] : null,
          onTap: () => Get.offAllNamed('/'),
        ),
        ListTile(
          title: const Text('Targets'),
          leading: const Icon(Icons.check_box_outlined),
          tileColor: Get.currentRoute == '/targets' ? Colors.grey[300] : null,
          onTap: () => Get.offAllNamed('/targets'),
        ),
        const ListTile(
          leading: Icon(Icons.logout),
          title: Text('Log Out'),
          onTap: navigateToLoginPage,
        ),
      ],
    ));
  }
}

String getInitials(String name) => name.isNotEmpty
    ? name.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join()
    : '';

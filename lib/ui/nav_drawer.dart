import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/expense_controller.dart';
import '../controller/home_controller.dart';
import '../controller/targets_controller.dart';
import '../utils/utils.dart';
import 'insert_edit_expense_dialog.dart';
import 'insert_edit_target_dialog.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (_) => Drawer(
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
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
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
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  Text(currentUser?.email ?? "Email",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary))
                ],
              )),
          ...HomeController.navEntries.map<Widget>((entry) => ListTile(
                title: Text(entry.drawerTitle),
                leading: entry.drawerIcon,
                tileColor: _.currentEntry.screen == entry.screen
                    ? Colors.grey[300]
                    : null,
                onTap: entry.onDrawerTap,
              )),
        ],
      )),
    );
  }
}

void showCreateExpenseDialog() async {
  await Get.find<ExpenseController>().refreshInsertEditExpenseControllers();
  showDialog<bool?>(
    context: Get.context!,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) =>
        InsertEditExpenseDialog(ExpenseDialogMode.insert),
  );
}

void showCreateTargetDialog() {
  Get.find<TargetsController>().refreshInsertEditTargetControllers();
  showDialog<bool?>(
    context: Get.context!,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) =>
        const InsertEditTargetDialog(TargetDialogMode.insert),
  );
}

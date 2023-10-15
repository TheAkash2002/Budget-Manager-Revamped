import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ui/components/nav_drawer.dart';
import '../ui/dialogs/expenses_filter_modal.dart';
import '../ui/screens/bar_pie_chart.dart';
import '../ui/screens/expenses.dart';
import '../ui/screens/relative_change.dart';
import '../ui/screens/settings.dart';
import '../ui/screens/targets.dart';
import '../utils/auth.dart';
import 'expense.dart';
import 'loading_mixin.dart';
import 'targets.dart';

enum HomeScreen {
  expenses,
  targets,
  logout,
  settings,
  bar_pie,
  relative_change
}

/// Controller for Home screen.
class HomeController extends GetxController with LoadingMixin {
  HomeNavigationEntry currentEntry = navEntries
      .where((element) => element.screen == HomeScreen.expenses)
      .toList()[0];

  void setScreen(HomeScreen newScreen) {
    currentEntry =
        navEntries.where((element) => element.screen == newScreen).toList()[0];
    update();

    //Dismiss Drawer
    Navigator.of(Get.context!).pop();
  }

  static void showFilterModal() => showModalBottomSheet(
      context: Get.context!, builder: (context) => const ExpensesFilterModal());

  static void downloadExpenses() =>
      Get.find<ExpenseController>().downloadExpenses();

  static void downloadTargets() =>
      Get.find<TargetsController>().downloadTargets();

  static List<HomeNavigationEntry> navEntries = [
    HomeNavigationEntry(
      screen: HomeScreen.expenses,
      widget: const Expenses(),
      screenTitle: 'Expenses',
      actions: [
        const IconButton(
          onPressed: downloadExpenses,
          icon: Icon(Icons.download),
          tooltip: 'Download Expenses',
        ),
        const IconButton(
          onPressed: showFilterModal,
          icon: Icon(Icons.filter_list),
          tooltip: 'Filter',
        ),
      ],
      fab: const FloatingActionButton(
        onPressed: showCreateExpenseDialog,
        tooltip: 'Create New Expense',
        child: Icon(Icons.add),
      ),
      drawerIcon: const Icon(Icons.attach_money),
      drawerTitle: 'Expenses',
    ),
    HomeNavigationEntry(
      screen: HomeScreen.targets,
      widget: const Targets(),
      screenTitle: 'Monthly Targets',
      actions: [
        const IconButton(
          onPressed: downloadTargets,
          icon: Icon(Icons.download),
          tooltip: 'Download Targets',
        ),
      ],
      fab: const FloatingActionButton(
        onPressed: showCreateTargetDialog,
        tooltip: 'Create New Target',
        child: Icon(Icons.add),
      ),
      drawerIcon: const Icon(Icons.check_box_outlined),
      drawerTitle: 'Targets',
    ),
    HomeNavigationEntry(
      screen: HomeScreen.bar_pie,
      widget: const BarPieChart(),
      screenTitle: 'Bar / Pie Chart',
      actions: [],
      drawerIcon: const Icon(Icons.add_chart),
      drawerTitle: 'Bar / Pie Chart',
    ),
    HomeNavigationEntry(
      screen: HomeScreen.relative_change,
      widget: const RelativeChange(),
      screenTitle: 'Line Chart',
      actions: [],
      drawerIcon: const Icon(Icons.multiline_chart),
      drawerTitle: 'Line Chart',
    ),
    HomeNavigationEntry(
      screen: HomeScreen.settings,
      widget: const Settings(),
      screenTitle: 'Settings',
      actions: [],
      drawerIcon: const Icon(Icons.settings),
      drawerTitle: 'Settings',
    ),
    HomeNavigationEntry(
      screen: HomeScreen.logout,
      widget: Container(),
      screenTitle: 'Log Out',
      actions: [],
      onTap: navigateToLoginPage,
      drawerIcon: const Icon(Icons.logout),
      drawerTitle: 'Log Out',
    )
  ];
}

/// Class representing a screen accessible from the Home page.
class HomeNavigationEntry {
  HomeScreen screen;
  Widget widget;
  String screenTitle;
  List<IconButton> actions;
  FloatingActionButton? fab;
  Icon drawerIcon;
  String drawerTitle;
  void Function() onDrawerTap;

  HomeNavigationEntry(
      {required this.screen,
      required this.widget,
      required this.screenTitle,
      required this.actions,
      this.fab,
      required this.drawerIcon,
      required this.drawerTitle,
      void Function()? onTap})
      : onDrawerTap =
            onTap ?? (() => Get.find<HomeController>().setScreen(screen));
}

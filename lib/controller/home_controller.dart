import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/auth.dart';
import '../ui/expenses_page.dart';
import '../ui/list_filter.dart';
import '../ui/nav_drawer.dart';
import '../ui/settings_page.dart';
import '../ui/targets_page.dart';

enum HomeScreen { expenses, targets, logout, settings }

class HomeController extends GetxController {
  bool isLoading = false;
  HomeNavigationEntry currentEntry = navEntries
      .where((element) => element.screen == HomeScreen.expenses)
      .toList()[0];

  @override
  void onInit() {
    super.onInit();
    if (!isLoggedIn()) {
      navigateToLoginPage();
    }
  }

  void setLoadingState(bool newState) {
    isLoading = newState;
    update();
  }

  void setScreen(HomeScreen newScreen) {
    currentEntry =
        navEntries.where((element) => element.screen == newScreen).toList()[0];
    update();
    Navigator.of(Get.context!).pop();
  }

  Future<void> signOutUser() async {
    setLoadingState(true);
    await signOut();
    setLoadingState(false);
  }

  static List<HomeNavigationEntry> navEntries = [
    HomeNavigationEntry(
      screen: HomeScreen.expenses,
      widget: const Expenses(),
      screenTitle: "Expenses",
      actions: [
        IconButton(
          onPressed: () => showModalBottomSheet(
              context: Get.context!, builder: (context) => const ListFilter()),
          icon: const Icon(Icons.filter_list),
          tooltip: "Filter",
        ),
      ],
      fab: const FloatingActionButton(
        onPressed: showCreateExpenseDialog,
        tooltip: "Create New Expense",
        child: Icon(Icons.add),
      ),
      drawerIcon: const Icon(Icons.attach_money),
      drawerTitle: "Expenses",
    ),
    HomeNavigationEntry(
      screen: HomeScreen.targets,
      widget: const Targets(),
      screenTitle: "Monthly Targets",
      actions: [],
      fab: const FloatingActionButton(
        onPressed: showCreateTargetDialog,
        tooltip: "Create New Target",
        child: Icon(Icons.add),
      ),
      drawerIcon: const Icon(Icons.check_box_outlined),
      drawerTitle: "Targets",
    ),
    HomeNavigationEntry(
      screen: HomeScreen.settings,
      widget: const Settings(),
      screenTitle: "Settings",
      actions: [],
      drawerIcon: const Icon(Icons.settings),
      drawerTitle: "Settings",
    ),
    HomeNavigationEntry(
      screen: HomeScreen.logout,
      widget: Container(),
      screenTitle: "Log Out",
      actions: [],
      onTap: navigateToLoginPage,
      drawerIcon: const Icon(Icons.logout),
      drawerTitle: "Log Out",
    )
  ];
}

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

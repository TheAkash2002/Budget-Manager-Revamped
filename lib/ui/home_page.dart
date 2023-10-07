import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../utils/navigation.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(_.currentEntry.screenTitle),
          actions: _.currentEntry.actions,
        ),
        drawer: const NavDrawer(),
        body: _.currentEntry.widget,
        floatingActionButton: _.currentEntry.fab,
      ),
    );
  }
}

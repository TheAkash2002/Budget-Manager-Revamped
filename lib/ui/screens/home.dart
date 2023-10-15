import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home.dart';
import '../components/custom_components.dart';
import '../components/nav_drawer.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(_.currentEntry.screenTitle),
          actions: _.currentEntry.actions,
        ),
        drawer: const NavDrawer(),
        body: Stack(
          children: [
            _.currentEntry.widget,
            if (_.isLoading) const Loading(),
          ],
        ),
        floatingActionButton: _.currentEntry.fab,
      ),
    );
  }
}

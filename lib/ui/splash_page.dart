import 'package:budget_manager_revamped/controller/splash_controller.dart';
import 'package:budget_manager_revamped/ui/custom_components.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (_) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: Stack(children: [
            Center(
              child: Text(
                "Budget Manager\nRevamped",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            if (_.isLoading) const Loading(),
          ])),
    );
  }
}

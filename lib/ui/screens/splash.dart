import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/splash.dart';
import '../components/custom_components.dart';

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
                'Budget Manager\nRevamped',
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

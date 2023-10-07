import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../controller/auth_controller.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (_) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: Stack(children: [
            Center(
              child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 500,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Budget Manager\nRevamped",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: ElevatedButton(
                              onPressed: _.signInUser,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(100, 50),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(Icons.android),
                                    SizedBox(width: 12),
                                    Text('Sign in with Google'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),
                  )),
            ),
            if (_.isLoading)
              Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                    color: Theme.of(context).colorScheme.background, size: 60),
              )
          ])),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth.dart';
import '../components/custom_components.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(),
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
                            'Budget Manager\nRevamped',
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
            if (_.isLoading) const Loading()
          ])),
    );
  }
}

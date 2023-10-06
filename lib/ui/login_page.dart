import 'package:flutter/material.dart';

import '../auth/auth.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 500,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text(
                    "Budget Manager - Revamped",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: ElevatedButton(
                      onPressed: signIn,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.android),
                            // <-- Use 'Image.asset(...)' here
                            SizedBox(width: 12),
                            Text('Sign in with Google'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              )),
        ));
  }
}

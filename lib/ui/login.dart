import 'package:flutter/material.dart';

import '../auth/auth.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: ElevatedButton(onPressed: signIn, child: Text("Sign In")),
    ));
  }
}

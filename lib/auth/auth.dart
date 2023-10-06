import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/utils.dart';

Future<UserCredential> signInWithGoogle() async {
  if (kIsWeb) {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

void signIn() async {
  try {
    UserCredential credential = await signInWithGoogle();
    if (credential.user != null) {
      showToast("Logged in successfully.");
      Get.offAllNamed('/');
    } else {
      showToast("Invalid user - try logging in again.");
    }
  } catch (e) {
    showToast("Some error occured.");
    print(e);
  }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
  if (!kIsWeb) {
    await GoogleSignIn().signOut();
  }
  showToast("User logged out successfully.");
}

/// Opens [Login] after a logout operation.
void navigateToLoginPage() async {
  try {
    await signOut();
    Get.offAllNamed('/login');
  } catch (_) {
    showToast("There was an error in logging the user out.");
  }
}

bool isLoggedIn() => FirebaseAuth.instance.currentUser != null;

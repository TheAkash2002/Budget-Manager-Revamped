import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';

/**
 * Auth Utils
 */

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

Future<void> signIn() async {
  try {
    UserCredential credential = await signInWithGoogle();
    if (credential.user != null) {
      showToast("Success", "Logged in successfully.");
      Get.offAllNamed('/');
    } else {
      showToast("Error", "Invalid user - try logging in again.");
    }
  } catch (e) {
    showToast("Error", "Some error occured.");
    log.severe(e);
  }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
  if (!kIsWeb) {
    await GoogleSignIn().signOut();
  }
  showToast("Success", "User logged out successfully.");
}

/// Opens [Login] after a logout operation.
void navigateToLoginPage() async {
  try {
    await signOut();
    Get.offAllNamed('/login');
  } catch (_) {
    showToast("Error", "There was an error in logging the user out.");
  }
}

bool isLoggedIn() => FirebaseAuth.instance.currentUser != null;

User? currentUser = FirebaseAuth.instance.currentUser;

/**
 * Theme Utils
 */

/// Name of GetStorage container responsible for the app theme.
const String THEME_CONTAINER = "Theme";

/// Name of property holding the index of the app theme color in [themeBaseColors].
const String COLOR_PROPERTY = "color";

/// Choices of base colors for the app theme.
final List<MaterialColor> themeBaseColors = [
  Colors.deepPurple,
  Colors.green,
  Colors.blue,
  Colors.amber,
  Colors.deepOrange,
  Colors.pink,
  Colors.brown,
  Colors.lime,
  Colors.teal,
  Colors.cyan,
];

ThemeData applyFontAndStatusBar(ThemeData baseTheme) => baseTheme.copyWith(
      textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme),
      appBarTheme: baseTheme.appBarTheme.copyWith(
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent)),
    );

void changeTheme(MaterialColor color) async {
  await GetStorage(THEME_CONTAINER)
      .write(COLOR_PROPERTY, themeBaseColors.indexOf(color));
  Get.changeTheme(applyFontAndStatusBar(ThemeData(primarySwatch: color)));
}

ThemeData loadThemeData() {
  int index = GetStorage(THEME_CONTAINER).read<int>(COLOR_PROPERTY) ?? 0;
  return applyFontAndStatusBar(
      ThemeData(primarySwatch: themeBaseColors[index]));
}

/**
 * Date Utils
 */

/// Opens a [DatePicker] widget.
void openDatePicker(BuildContext context, DateTime? initialDate,
    void Function(DateTime) callback) async {
  try {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2050),
    );
    if (newDate != null) {
      callback(newDate);
    }
  } catch (_) {
    showToast("Error", "There was an error in capturing the date.");
  }
}

DateTime getFirstDayOfMonth(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month);
}

DateTime getLastDayOfMonth(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month + 1, 0);
}

/// Lists out the days between a start date and an end date.
Iterable<DateTime> daysInRange(DateTime start, DateTime end) sync* {
  var i = start;
  var offset = start.timeZoneOffset;
  while (i.isBefore(end)) {
    yield i;
    i = i.add(const Duration(days: 1));
    var timeZoneDiff = i.timeZoneOffset - offset;
    if (timeZoneDiff.inSeconds != 0) {
      offset = i.timeZoneOffset;
      i = i.subtract(Duration(seconds: timeZoneDiff.inSeconds));
    }
  }
}

/// Lists out the months between a start date and an end date.
Iterable<DateTime> monthsInRange(DateTime start, DateTime end) {
  Iterable<DateTime> days = daysInRange(start, end);
  final map =
      groupBy<DateTime, DateTime>(days, (day) => DateTime(day.year, day.month));
  return map.keys;
}

/// Log Utils

final log = Logger("Logs");

void configureLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

String getInitials(String name) => name.isNotEmpty
    ? name.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join()
    : '';

/// Utility to display [message] as a toast.
void showToast(String title, String message) {
  ScaffoldMessenger.of(Get.context!)
      .showSnackBar(SnackBar(content: Text(message)));
  return;
  Get.snackbar(
    title,
    message,
    colorText: Theme.of(Get.context!).colorScheme.onSurface,
    backgroundColor: Theme.of(Get.context!).colorScheme.surface,
    icon: Icon(
      Icons.add_alert,
      color: Theme.of(Get.context!).colorScheme.onSurface,
    ),
  );
}

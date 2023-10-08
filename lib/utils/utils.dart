import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';

/// Utility to display [message] as a toast.
void showToast(String title, String message) {
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

String getInitials(String name) => name.isNotEmpty
    ? name.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join()
    : '';

final log = Logger("Logs");

void configureLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

ThemeData applyFont(ThemeData baseTheme) => baseTheme.copyWith(
    textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme));

void changeTheme(MaterialColor color) {
  GetStorage('Theme').write("color", themeBaseColors.indexOf(color));
  Get.changeTheme(applyFont(ThemeData(primarySwatch: color)));
}

ThemeData loadThemeData() {
  int index = GetStorage("Theme").read("color") ?? 0;
  return applyFont(ThemeData(primarySwatch: themeBaseColors[index]));
}

List<MaterialColor> themeBaseColors = [
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

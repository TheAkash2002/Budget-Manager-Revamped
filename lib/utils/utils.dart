import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';

import '../firebase_options.dart';
import 'theme.dart';

/**
 * Main app initialization
 */

Future<void> initializeMainApp() async {
  configureLogger();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]);
  await GetStorage.init(THEME_CONTAINER);
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
    showToast('Error', 'There was an error in capturing the date.');
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

final log = Logger('Logs');

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

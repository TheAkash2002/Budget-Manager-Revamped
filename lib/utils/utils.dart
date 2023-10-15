import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    showToast(ToastType.error, 'There was an error in capturing the date.');
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

FToast fToast = FToast();

void attachFToast() {
  fToast.init(Get.context!);
}

enum ToastType { success, warning, error }

extension ToastStyle on ToastType {
  Color color() {
    switch (this) {
      case ToastType.success:
        return Colors.greenAccent;

      case ToastType.warning:
        return Colors.yellowAccent;

      case ToastType.error:
        return Colors.redAccent;
    }
  }

  Icon icon() {
    switch (this) {
      case ToastType.success:
        return const Icon(Icons.check);
      case ToastType.warning:
        return const Icon(Icons.warning_amber);
      case ToastType.error:
        return const Icon(Icons.error);
    }
  }
}

/// Utility to display [message] as a toast.
void showToast(ToastType type, String message) {
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: type.color(),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        type.icon(),
        const SizedBox(width: 12.0),
        Expanded(child: Text(message)),
      ],
    ),
  );
  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: const Duration(seconds: 2),
  );
  return;
}

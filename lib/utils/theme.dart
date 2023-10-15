import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

/// Name of GetStorage container responsible for the app theme.
const String THEME_CONTAINER = 'Theme';

/// Name of property holding the index of the app theme color in [themeBaseColors].
const String COLOR_PROPERTY = 'color';

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

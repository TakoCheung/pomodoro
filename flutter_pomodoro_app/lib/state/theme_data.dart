import 'package:flutter/material.dart';

const ColorScheme lightColorScheme = ColorScheme.light(
  primary: Color(0xFFF87070),
  secondary: Color(0xFF70F3F8),
  surface: Color(0xFF2E325A),
  onPrimary: Colors.white,
  onSecondary: Colors.black,
);

const ColorScheme darkColorScheme = ColorScheme.dark(
  primary: Color(0xFF181C33),
  secondary: Color(0xFF7B81E3),
  surface: Color(0xFF2A2E47),
  onPrimary: Colors.white,
  onSecondary: Colors.black,
);

const TextTheme lightTextTheme = TextTheme(
  displayLarge: TextStyle(
    fontSize: 100,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'KumbhSans'
  ),
  displayMedium: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'RobotoSlab'
  ),
  bodyLarge: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'spaceMono'
  ),
  bodyMedium: TextStyle(
    fontSize: 12,
    color: Colors.white,
    fontFamily: 'spaceMono'
  ),
);

const TextTheme darkTextTheme = TextTheme(
  displayLarge: TextStyle(
    fontSize: 100,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: 'KumbhSans'
  ),
  displayMedium: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: 'RobotoSlab'
  ),
  bodyLarge: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: 'spaceMono'
  ),
  bodyMedium: TextStyle(
    fontSize: 12,
    color: Colors.black,
    fontFamily: 'spaceMono'
  ),
);

ThemeData getAppTheme({required bool isDarkMode}) {
  return ThemeData(
    textTheme: isDarkMode ? darkTextTheme : lightTextTheme,
    primaryColor: isDarkMode ? darkColorScheme.primary : lightColorScheme.primary,
    scaffoldBackgroundColor: isDarkMode ? darkColorScheme.surface : lightColorScheme.surface,
    buttonTheme: ButtonThemeData(
      buttonColor: isDarkMode ? darkColorScheme.primary : lightColorScheme.primary,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: isDarkMode ? darkColorScheme.primary : lightColorScheme.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ), colorScheme: isDarkMode ? darkColorScheme : lightColorScheme.copyWith(surface: isDarkMode ? darkColorScheme.surface : lightColorScheme.surface),
  );
}

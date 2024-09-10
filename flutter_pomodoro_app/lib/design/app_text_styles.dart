import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';

class AppTextStyles {
  static const double h1FontSize = 100;
  static const double h2FontSize = 28;
  static const double h3FontSize = 16;
  static const double h4FontSize = 13;
  static const double bodyFontSize = 14;
  static const double body2FontSize = 12;
  static const double title = 32;

  static const double h1LetterSpacing = -5;
  static const double h3LetterSpacing = 15;
  static const double h4LetterSpacing = 5;

  static const double h1LineSpacing = 1.2;
  static const double h2LineSpacing = 1.214;
  static const double h3LineSpacing = 1.1875;
  static const double h4LineSpacing = 1.231;
  static const double bodyLineSpacing = 1.29;
  static const double body2LineSpacing = 1.17;

  static const String kumbhSans = 'KumbhSans';
  static const String robotoSlab = 'RobotoSlab';
  static const String spaceMono = 'SpaceMono';

  static const String pomodoro = 'pomodoro';
  static const String shortBreak = 'short break';
  static const String longBreak = 'long break';

  static const TextStyle h4 = TextStyle(
    fontSize: AppTextStyles.h4FontSize,
    fontWeight: FontWeight.bold,
    fontFamily: AppTextStyles.kumbhSans,
    letterSpacing: AppTextStyles.h4LetterSpacing,
    height: AppTextStyles.h4LineSpacing,
    color: AppColors.darkDarkBlue,
  );
}

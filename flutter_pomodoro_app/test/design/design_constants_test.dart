import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/design/app_magic_number.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';

void main(){
  test('AppMagicNumber sixty is 60', (){
    expect(AppMagicNumber.sixty, 60);
  });

  test('AppColors contains expected colors', (){
    expect(AppColors.orangeRed, const Color(0xFFF87070));
    expect(AppColors.lightBlue, const Color(0xFF70F3F8));
    expect(AppColors.darkBlue, const Color(0xFF1E213F));
  });

  test('AppTextStyles constants', (){
    expect(AppTextStyles.h1FontSize, 100);
    expect(AppTextStyles.kumbhSans, 'KumbhSans');
    expect(AppTextStyles.h4.color, AppColors.darkDarkBlue);
  });
}

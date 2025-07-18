import 'package:flutter/material.dart';

class BidElevatedButtonTheme {
  BidElevatedButtonTheme._();

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Color(0xffFFE70C),
      backgroundColor: Color(0xffFFE70C),
      disabledForegroundColor: Color(0xffFFE70C),
      disabledBackgroundColor: Color(0xffFFE70C),
      side: const BorderSide(color: Color(0xffFFE70C)),
      padding: const EdgeInsets.symmetric(vertical: 10),
      textStyle: const TextStyle(
          fontSize: 16, color: Color(0xff333333), fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Color(0xffFFE70C),
      backgroundColor: Color(0xffFFE70C),
      disabledForegroundColor: Color(0xffFFE70C),
      disabledBackgroundColor: Color(0xffFFE70C),
      side: const BorderSide(color: Color(0xffFFE70C)),
      padding: const EdgeInsets.symmetric(vertical: 10),
      textStyle: const TextStyle(
          fontSize: 16, color: Color(0xff333333), fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

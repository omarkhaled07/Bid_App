import 'package:bid/utils/theme/Custom_themes/app_bar_theme.dart';
import 'package:bid/utils/theme/Custom_themes/button_sheet_theme.dart';
import 'package:bid/utils/theme/Custom_themes/check_box_theme.dart';
import 'package:bid/utils/theme/Custom_themes/chip_theme.dart';
import 'package:bid/utils/theme/Custom_themes/elevated_button_theme.dart';
import 'package:bid/utils/theme/Custom_themes/outlined_button_theme.dart';
import 'package:bid/utils/theme/Custom_themes/text_field_theme.dart';
import 'package:bid/utils/theme/Custom_themes/text_theme.dart';
import 'package:flutter/material.dart';

class BidAppTheme {
  BidAppTheme._();

  static ThemeData lighttheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Lato",
    brightness: Brightness.light,
    primaryColor: Color(0xffE5FAF9),
    scaffoldBackgroundColor: Colors.white,
    textTheme: BidTextTheme.lightTextTheme, // Reference to your TextTheme
    chipTheme: BidChipTheme.lightChipTheme, // Reference to your ChipTheme
    appBarTheme:
    BidAppBarTheme.lightAppBarTheme, // Reference to your AppBarTheme
    checkboxTheme:
    BidCheckboxTheme.lightCheckboxTheme, // Reference to your CheckboxTheme
    bottomSheetTheme:
    BidBottomSheetTheme.lightBottomSheetTheme, // Corrected typo in the name
    elevatedButtonTheme: BidElevatedButtonTheme
        .lightElevatedButtonTheme, // Reference to your ElevatedButtonTheme
    outlinedButtonTheme: BidOutlinedButtonTheme
        .lightOutlinedButtonTheme, // Reference to your OutlinedButtonTheme
    inputDecorationTheme: BidTextFormFieldTheme
        .lightInputDecorationTheme, // Reference to your InputDecorationTheme
  );
  static ThemeData darktheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Lato",
    brightness: Brightness.dark,
    primaryColor: Color(0xff080618),
    scaffoldBackgroundColor: Colors.black,
    textTheme: BidTextTheme.darkTextTheme, // Reference to your TextTheme
    chipTheme: BidChipTheme.darkChipTheme, // Reference to your ChipTheme
    appBarTheme:
    BidAppBarTheme.darkAppBarTheme, // Reference to your AppBarTheme
    checkboxTheme:
    BidCheckboxTheme.darkCheckboxTheme, // Reference to your CheckboxTheme
    bottomSheetTheme:
    BidBottomSheetTheme.darkBottomSheetTheme, // Corrected typo in the name
    elevatedButtonTheme: BidElevatedButtonTheme
        .darkElevatedButtonTheme, // Reference to your ElevatedButtonTheme
    outlinedButtonTheme: BidOutlinedButtonTheme
        .darkOutlinedButtonTheme, // Reference to your OutlinedButtonTheme
    inputDecorationTheme: BidTextFormFieldTheme
        .darkInputDecorationTheme, // Reference to your InputDecorationTheme
  );
}

import 'package:flutter/material.dart';

class BidChipTheme {
  BidChipTheme._(); // To avoid creating instances

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: const Color.fromRGBO(128, 128, 128, 0.4), // 0.4 opacity
    labelStyle: const TextStyle(color: Colors.black),
    selectedColor: Colors.blue,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    checkmarkColor: Colors.white,
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    disabledColor: Colors.grey,
    labelStyle: TextStyle(color: Colors.white),
    selectedColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    checkmarkColor: Colors.white,
  );
}

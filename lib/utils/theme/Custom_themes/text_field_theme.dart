import 'package:flutter/material.dart';

/// TextFormField Theme Class
class BidTextFormFieldTheme {
  BidTextFormFieldTheme._(); // To avoid creating instances

  static final InputDecorationTheme lightInputDecorationTheme =
  InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    // Customizing Text Styles
    labelStyle: const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    hintStyle: const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    errorStyle: const TextStyle(
      fontStyle: FontStyle.normal,
      color: Colors.red,
    ),
    floatingLabelStyle: const TextStyle(
      color: Colors.black,
    ),
    // Border Styles
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: Colors.black12),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 2, color: Colors.red),
    ),
  );

  static final InputDecorationTheme darkInputDecorationTheme =
  InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    labelStyle: const TextStyle(
      fontSize: 14,
      color: Colors.white,
    ),
    hintStyle: const TextStyle(
      fontSize: 14,
      color: Colors.white,
    ),
    floatingLabelStyle: const TextStyle(
      color: Colors.white,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(width: 1, color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(width: 1, color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(width: 1, color: Colors.white),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(width: 1, color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(width: 2, color: Colors.orange),
    ),
  );
}

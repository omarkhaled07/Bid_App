import 'package:flutter/material.dart';

class BidColors {
  BidColors._();

  //Bid Basic Colors

  static const Color primary = Color(0xffE5FAF9);
  static const Color secondery = Color(0xff080618);

  static const Gradient linerGradient = LinearGradient(
      begin: Alignment(0.0, 0.0),
      end: Alignment(0.707, -0.787),
      colors: [
        Color(0xff86D2C5),
        Color(0xffffffff),
        Color(0xffD3F7F5),
      ]);
}

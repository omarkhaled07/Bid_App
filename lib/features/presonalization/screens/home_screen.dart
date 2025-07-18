import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final bgColor = isDarkMode ? Color(0xff080618) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("home_screen".tr, style: TextStyle(color: textColor)),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
      ),
      body: Center(
        child: Text(
          "welcome_message".tr,
          style: TextStyle(fontSize: 24, color: textColor),
        ),
      ),
    );
  }
}
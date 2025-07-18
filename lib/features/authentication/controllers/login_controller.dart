import 'package:bid/features/shop/screens/cart_screen.dart';
import 'package:bid/features/shop/screens/shop_home_screen/shop_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presonalization/screens/home_screen.dart';

class ControlViewModel extends GetxController {
  int _navigatorValue = 0;

  get navigatorValue => _navigatorValue;

  Widget currentScreen = ShopHomeScreen();

  void changeSelectedValue(int selectedValue) {
    _navigatorValue = selectedValue;
    switch (selectedValue) {
      case 0:
        {
          currentScreen = ShopHomeScreen();
          break;
        }
      case 1:
        {
          currentScreen = CartScreen();
          break;
        }
      case 2:
        {
          currentScreen = HomeScreen();
          break;
        }
    }
    update();
  }
}

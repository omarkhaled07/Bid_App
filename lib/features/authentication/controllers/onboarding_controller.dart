import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shop/screens/shop_home_screen/shop_home_screen.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  // Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  // Update Current Index when Page Scrolls
  void updatePageIndicator(index) => currentPageIndex.value = index;

  // Jump to the specific dot-selected page
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  // Update Current Index & jump to the next page
  Future<void> nextPage() async {
    if (currentPageIndex.value < 2) {
      // إذا لم نصل إلى آخر صفحة، انتقل للصفحة التالية
      int nextPage = currentPageIndex.value + 1;
      pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // عند الوصول إلى آخر صفحة، خزّن الحالة وانتقل للصفحة الرئيسية
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("hasSeenOnboarding", true);
      Get.off(() => ShopHomeScreen()); // يغلق الـ OnBoarding وينتقل للـ Home مباشرة
    }
  }

  // Update Current Index & jump to the last page
  Future<void> skipPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("hasSeenOnboarding", true);
    Get.off(() => ShopHomeScreen());
  }
}

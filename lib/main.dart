import 'package:bid/features/shop/screens/shop_home_screen/shop_home_screen.dart';
import 'package:bid/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/authentication/controllers/auth_controller.dart';
import 'features/authentication/models/auth_view_model.dart';
import 'features/shop/models/home_view_model.dart';
import 'features/authentication/screens/onboarding/onboarding.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 تهيئة GetStorage
  await GetStorage.init();

  // 🔹 إضافة ViewModels وControllers
  Get.put(AuthViewModel());
  Get.put(HomeViewModel());
  Get.put(AuthController());


  // 🔹 التحقق من حالة المستخدم
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool("hasSeenOnboarding") ?? false;
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

  runApp(Bid(isLoggedIn: isLoggedIn, hasSeenOnboarding: hasSeenOnboarding));
}

class Bid extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool isLoggedIn;

  const Bid({super.key, required this.isLoggedIn, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: BidAppTheme.lighttheme,
      darkTheme: BidAppTheme.darktheme,
      debugShowCheckedModeBanner: false,
      home: hasSeenOnboarding ? ShopHomeScreen() : OnBoardingScreen(),
    );
  }
}

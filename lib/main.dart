import 'package:bid/features/shop/screens/shop_home_screen/shop_home_screen.dart';
import 'package:bid/utils/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_startup.dart';
import 'features/authentication/controllers/auth_controller.dart';
import 'features/authentication/models/auth_view_model.dart';
import 'features/authentication/screens/Login/login_screen.dart';
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
  bool isGuestMode = prefs.getBool("isGuestMode") ?? false;
  final hasFirebaseUser = FirebaseAuth.instance.currentUser != null;

  runApp(
    Bid(
      isLoggedIn: isLoggedIn && hasFirebaseUser,
      isGuestMode: isGuestMode && !hasFirebaseUser,
      hasSeenOnboarding: hasSeenOnboarding,
    ),
  );
}

class Bid extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool isLoggedIn;
  final bool isGuestMode;

  const Bid(
      {super.key,
      required this.isLoggedIn,
      required this.isGuestMode,
      required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    final StartupRoute startupRoute = resolveStartupRoute(
      hasSeenOnboarding: hasSeenOnboarding,
      isLoggedIn: isLoggedIn,
      isGuestMode: isGuestMode,
    );

    final Widget initialScreen = switch (startupRoute) {
      StartupRoute.onboarding => const OnBoardingScreen(),
      StartupRoute.home => const ShopHomeScreen(),
      StartupRoute.login => LoginScreen(),
    };

    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: BidAppTheme.lighttheme,
      darkTheme: BidAppTheme.darktheme,
      debugShowCheckedModeBanner: false,
      home: initialScreen,
    );
  }
}

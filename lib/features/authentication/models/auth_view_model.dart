import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../localization/fire_store_user.dart';
import '../../shop/models/user_model.dart';
import '../../shop/screens/shop_home_screen/shop_home_screen.dart';
import '../screens/Login/login_screen.dart';

class AuthViewModel extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage storage = GetStorage();
  final Rx<User?> _user = Rx<User?>(null);

  String? get user => _user.value?.email;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _persistLoginState(email);
      Get.offAll(() => const ShopHomeScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login failed',
        e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Login failed',
        'Unexpected error occurred.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userEmail');
    await storage.remove('isLoggedIn');
    await storage.remove('userEmail');
    await _auth.signOut();
    Get.offAll(() => LoginScreen());
  }

  Future<bool> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool storedLogin = prefs.getBool('isLoggedIn') ?? false;
    return storedLogin && _auth.currentUser != null;
  }

  Future<void> createAccountWithEmailAndPassword(
    String name,
    String email,
    String password,
    String phone,
    String userType,
    String countryCode,
    String countryName,
  ) async {
    if (!_isValidEmail(email)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!_isValidPassword(password)) {
      Get.snackbar(
        'Error',
        'Password must be at least 8 chars with upper/lower letters and numbers.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!_isValidPhone(countryCode, phone)) {
      Get.snackbar(
        'Error',
        'Please enter a valid phone number.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'userId': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'userType': userType,
        'countryCode': countryCode,
        'countryName': countryName,
        'pic': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _persistLoginState(email);
      Get.offAll(() => const ShopHomeScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Sign up failed',
        e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Sign up failed',
        'Unexpected error occurred.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool _isValidEmail(String email) {
    final RegExp regex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final RegExp regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }

  bool _isValidPhone(String countryCode, String phone) {
    final RegExp countryCodeRegex = RegExp(r'^\+\d{1,3}$');
    final RegExp phoneRegex = RegExp(r'^\d{6,14}$');

    return countryCodeRegex.hasMatch(countryCode.trim()) &&
        phoneRegex.hasMatch(phone.trim());
  }

  Future<void> _persistLoginState(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await storage.write('isLoggedIn', true);
    await storage.write('userEmail', email);
  }

  void saveUser(UserCredential user, String name) async {
    await FireStoreUser().addUserToFireStore(
      UserModel(
        userId: user.user!.uid,
        email: user.user!.email!,
        name: name,
        profileImage: '',
      ),
    );
  }
}

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
  late String email, password, name;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage storage = GetStorage(); // إنشاء كائن GetStorage

  final Rx<User?> _user = Rx<User?>(null);

  String? get user => _user.value?.email;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
  }
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // 🔹 حفظ بيانات المستخدم بعد تسجيل الدخول
      storage.write("isLoggedIn", true);
      storage.write("userEmail", email);

      Get.offAll(() => ShopHomeScreen()); // الانتقال إلى الشاشة الرئيسية
    } catch (e) {
      Get.snackbar("خطأ في تسجيل الدخول", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Future<void> signInWithEmailAndPassword(String email, String password) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool("isLoggedIn", true);
  //
  //   try {
  //     await _auth.signInWithEmailAndPassword(email: email, password: password);
  //     Get.offAll(ShopHomeScreen());
  //   } on FirebaseAuthException catch (e) {
  //     String errorMessage;
  //     switch (e.code) {
  //       case 'user-not-found':
  //         errorMessage = 'No user found for that email.';
  //         break;
  //       case 'wrong-password':
  //         errorMessage = 'Incorrect password. Please try again.';
  //         break;
  //       case 'invalid-email':
  //         errorMessage = 'The email address is not valid.';
  //         break;
  //       default:
  //         errorMessage = e.message ?? 'An unknown error occurred.';
  //     }
  //     Get.snackbar(
  //       'Login Failed',
  //       errorMessage,
  //       colorText: Colors.white,
  //       backgroundColor: Colors.red,
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'An unexpected error occurred',
  //       colorText: Colors.white,
  //       backgroundColor: Colors.red,
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   }
  // }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("isLoggedIn");
    await _auth.signOut();
    Get.offAll(() => LoginScreen());
  }

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }

  Future<void> createAccountWithEmailAndPassword(
      String name, String email, String password, String phone, String userType , String countryCode, String countryName) async {
    try {
      // تحقق من صحة البريد الإلكتروني
      if (!_isValidEmail(email)) {
        Get.snackbar("خطأ", "يرجى إدخال بريد إلكتروني صالح", snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // تحقق من قوة كلمة المرور
      if (!_isValidPassword(password)) {
        Get.snackbar("خطأ", "كلمة المرور يجب أن تكون 8 أحرف على الأقل، تحتوي على رقم وحرف كبير وصغير.",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // تحقق من رقم الهاتف
      if (!_isValidPhone(countryCode,phone)) {
        Get.snackbar("خطأ", "يرجى إدخال رقم هاتف صالح ", snackPosition: SnackPosition.BOTTOM);
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "userId": userCredential.user!.uid,
        "name": name,
        "email": email,
        "phone": phone,
        "userType": userType,
        "countryCode": countryCode, // كود الدولة
        "countryName": countryName,
        "pic": "",
        "createdAt": FieldValue.serverTimestamp(),
      });

      Get.offAll(() => ShopHomeScreen());

    } catch (e) {
      Get.snackbar("خطأ في التسجيل", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // 🔹 التحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    final RegExp regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  // 🔹 التحقق من قوة كلمة المرور
  bool _isValidPassword(String password) {
    final RegExp regex = RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$");
    return regex.hasMatch(password);
  }

  // 🔹 التحقق من رقم الهاتف مع كود الدولة
  bool _isValidPhone(String countryCode, String phone) {
    final RegExp countryCodeRegex = RegExp(r'^\+\d{1,3}$'); // كود الدولة بصيغة +XX أو +XXX
    final RegExp phoneRegex = RegExp(r'^\d{6,14}$'); // رقم الهاتف بين 6 و 14 رقمًا

    return countryCodeRegex.hasMatch(countryCode.trim()) &&
        phoneRegex.hasMatch(phone.trim());
  }

  void saveUser(UserCredential user, String name) async {
    await FireStoreUser().addUserToFireStore(UserModel(
      userId: user.user!.uid,
      email: user.user!.email!,
      name: name,
      profileImage: '',
    ));
  }


}
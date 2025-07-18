import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoggedIn = false.obs;
  var userData = {}.obs;

  @override
  void onInit() {
    super.onInit();

    // 🔥 استخدم authStateChanges() للتعامل تلقائيًا مع تغييرات تسجيل الدخول
    _auth.authStateChanges().listen((User? user) {
      isLoggedIn.value = user != null;

      if (user != null) {
        fetchUserData(user.uid);
      } else {
        userData.value = {}; // تصفير بيانات المستخدم عند تسجيل الخروج
      }
    });
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ سيتم تحديث حالة isLoggedIn تلقائيًا عبر authStateChanges()
      await fetchUserData(userCredential.user!.uid);

      Get.offAllNamed('/home'); // الانتقال إلى الشاشة الرئيسية
    } catch (e) {
      Get.snackbar("خطأ", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      // ✅ لا داعي لتحديث isLoggedIn يدويًا، لأنه سيتم تحديثه تلقائيًا عبر authStateChanges()
      Get.offAllNamed('/login'); // الانتقال إلى شاشة تسجيل الدخول
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ أثناء تسجيل الخروج");
    }
  }

  Future<void> fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        userData.value = userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("❌ Error fetching user data: $e");
    }
  }
}

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
  final RxBool isGuestMode = false.obs;

  String? get user => _user.value?.email;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
    _loadGuestMode();
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _persistLoginState(email);
      Get.offAll(() => const ShopHomeScreen());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (_) {
      return 'Unexpected error occurred.';
    }
  }

  Future<void> signOut() async {
    await _clearSessionState();
    await _auth.signOut();
    Get.offAll(() => LoginScreen());
  }

  Future<String?> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      return 'No authenticated user found.';
    }

    final uid = user.uid;

    try {
      await _deleteUserSubcollection(
        _firestore.collection('users').doc(uid).collection('favorites'),
      );
      await _deleteUserSubcollection(
        _firestore.collection('carts').doc(uid).collection('items'),
      );

      await _deleteDocs(
        _firestore.collection('favorites').where('userId', isEqualTo: uid),
      );
      await _deleteDocs(
        _firestore.collection('payments').where('userId', isEqualTo: uid),
      );
      await _deleteDocs(
        _firestore.collection('addresses').where('uid', isEqualTo: uid),
      );
      await _deleteDocs(
        _firestore.collection('cards').where('userId', isEqualTo: uid),
      );

      final products = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: uid)
          .get();
      for (final product in products.docs) {
        await _deleteUserSubcollection(product.reference.collection('bids'));
        await product.reference.delete();
      }

      final cartDoc = _firestore.collection('carts').doc(uid);
      final cartSnapshot = await cartDoc.get();
      if (cartSnapshot.exists) {
        await cartDoc.delete();
      }

      final userDoc = _firestore.collection('users').doc(uid);
      final userSnapshot = await userDoc.get();
      if (userSnapshot.exists) {
        await userDoc.delete();
      }

      await user.delete();
      await _clearSessionState();
      await _auth.signOut();
      Get.offAll(() => LoginScreen());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'For security, please sign in again before deleting your account.';
      }
      return e.message ?? e.code;
    } catch (_) {
      return 'Failed to delete the account. Please try again.';
    }
  }

  Future<bool> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool storedLogin = prefs.getBool('isLoggedIn') ?? false;
    return storedLogin && _auth.currentUser != null;
  }

  Future<void> continueAsGuest() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.setBool('isGuestMode', true);
    await prefs.remove('userEmail');
    await storage.write('isLoggedIn', false);
    await storage.write('isGuestMode', true);
    await storage.remove('userEmail');
    if (_auth.currentUser != null) {
      await _auth.signOut();
    }
    isGuestMode.value = true;
    Get.offAll(() => const ShopHomeScreen());
  }

  Future<String?> createAccountWithEmailAndPassword(
    String name,
    String email,
    String password,
    String phone,
    String userType,
    String countryCode,
    String countryName,
  ) async {
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address.';
    }

    if (!_isValidPassword(password)) {
      return 'Password must be at least 8 chars with upper/lower letters and numbers.';
    }

    if (!_isValidPhone(countryCode, phone)) {
      return 'Please enter a valid phone number.';
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
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (_) {
      return 'Unexpected error occurred.';
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address.';
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (_) {
      return 'Something went wrong. Try again.';
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
    await prefs.setBool('isGuestMode', false);
    await prefs.setString('userEmail', email);
    await storage.write('isLoggedIn', true);
    await storage.write('isGuestMode', false);
    await storage.write('userEmail', email);
    isGuestMode.value = false;
  }

  Future<void> _loadGuestMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isGuestMode.value = prefs.getBool('isGuestMode') ?? false;
  }

  Future<void> _clearSessionState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('isGuestMode');
    await prefs.remove('userEmail');
    await storage.remove('isLoggedIn');
    await storage.remove('isGuestMode');
    await storage.remove('userEmail');
    isGuestMode.value = false;
  }

  Future<void> _deleteDocs(Query<Map<String, dynamic>> query) async {
    final snapshot = await query.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _deleteUserSubcollection(
      CollectionReference<Map<String, dynamic>> collection) async {
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
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

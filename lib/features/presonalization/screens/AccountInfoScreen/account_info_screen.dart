import 'package:bid/features/authentication/models/auth_model.dart';
import 'package:bid/features/presonalization/screens/EditProfileScreen/edit_profile_screen.dart';
import 'package:bid/features/shop/screens/shop_home_screen/shop_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../authentication/controllers/auth_controller.dart';

class AccountInfoScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const AccountInfoScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080618), // ✅ خلفية داكنة
      body: Column(
        children: [
          _buildAppBar(context),
          _buildHeader(),
          _buildUserInfo(),
          const SizedBox(height: 10),
          _buildEditButton(),
          const SizedBox(height: 10),
          _buildSignOutButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 40, left: 10),
      // ✅ لإضافة مسافة آمنة للأعلى
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.black, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(
            width: 20,
          ),
          CustomTextWidget(
              txt: "Account Info",
              txtsize: 18,
              txtColor: Colors.black,
              txtAlign: TextAlign.center)
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFF86D2C5)], // ✅ تدرج لوني داكن
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 48,
            backgroundImage: NetworkImage(
              userData['profileImage'] ?? "https://via.placeholder.com/150",
            ),
            onBackgroundImageError: (_, __) =>
                const Icon(Icons.person, size: 48, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: const Color(0xFF10172A), // ✅ لون Card أفتح قليلاً مع ظل خفيف
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.person, "Name", userData['name']),
              _buildInfoRow(Icons.email, "Email", userData['email']),
              _buildInfoRow(
                  Icons.phone, "Phone", userData['phone'] ?? "Not Available"),
              _buildInfoRow(Icons.location_on, "Address",
                  userData['address'] ?? "Not Available"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A90E2), size: 24),
          // ✅ لون أيقونات أزرق مميز
          const SizedBox(width: 10),
          Text(
            "$label:",
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0E0E0)), // ✅ لون نص أفتح
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFC0C0C0)), // ✅ لون نص رمادي فاتح
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFE70C), // ✅ لون زر التعديل
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => Get.to(() => EditProfileScreen()),
          child: const Text("Edit Profile",
              style: TextStyle(fontSize: 18, color: Color(0xff333333))),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFE70C), // ✅ لون زر تسجيل الخروج
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();

            // ✅ تحديث حالة المستخدم بعد تسجيل الخروج
            final authController = Get.find<AuthController>();
            authController.isLoggedIn.value = false;
            authController.userData.value = {};

            // ✅ إعادة توجيه المستخدم لشاشة البداية وتحديث الواجهة
            Get.offAll(() => ShopHomeScreen());
          },
          child: const Text("Sign Out",
              style: TextStyle(fontSize: 18, color: Color(0xff333333))),
        ),
      ),
    );
  }
}

import 'package:bid/features/authentication/models/auth_model.dart';
import 'package:bid/features/authentication/models/auth_view_model.dart';
import 'package:bid/features/presonalization/screens/EditProfileScreen/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountInfoScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const AccountInfoScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080618),
      body: Column(
        children: [
          _buildAppBar(context),
          _buildHeader(),
          _buildUserInfo(),
          const SizedBox(height: 10),
          _buildEditButton(),
          const SizedBox(height: 10),
          _buildSignOutButton(),
          const SizedBox(height: 10),
          _buildDeleteAccountButton(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 40, left: 10),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.black, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 20),
          const CustomTextWidget(
            txt: "Account Info",
            txtsize: 18,
            txtColor: Colors.black,
            txtAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFF86D2C5)],
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
        color: const Color(0xFF10172A),
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
          const SizedBox(width: 10),
          Text(
            "$label:",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE0E0E0),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFC0C0C0),
              ),
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
            backgroundColor: const Color(0xFFFFE70C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => Get.to(() => EditProfileScreen()),
          child: const Text(
            "Edit Profile",
            style: TextStyle(fontSize: 18, color: Color(0xff333333)),
          ),
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
            backgroundColor: const Color(0xFFFFE70C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => Get.find<AuthViewModel>().signOut(),
          child: const Text(
            "Sign Out",
            style: TextStyle(fontSize: 18, color: Color(0xff333333)),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () async {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text("Delete Account"),
                content: const Text(
                  "This action will permanently delete your profile and cannot be undone.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Delete"),
                  ),
                ],
              ),
            );

            if (shouldDelete != true) {
              return;
            }

            final error = await Get.find<AuthViewModel>().deleteAccount();
            if (error != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
            }
          },
          child: const Text(
            "Delete Account",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

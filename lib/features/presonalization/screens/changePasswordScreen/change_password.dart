import 'package:bid/features/authentication/models/auth_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();

  Future<void> _resetPassword() async {
    try {
      String email = emailController.text.trim();

      if (email.isEmpty) {
        Get.snackbar("Error", "Please enter your email",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);

      Get.snackbar("Success", "Password reset email sent to $email",
          backgroundColor: Colors.green, colorText: Colors.white);
      print("✅ Password reset email sent to $email");
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Error: ${e.code}");
      String errorMessage = "Failed to send email.";

      if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address.";
      } else if (e.code == 'user-not-found') {
        errorMessage = "No account found for this email.";
      }

      Get.snackbar("Error", errorMessage,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      print("❌ Unexpected Error: $e");
      Get.snackbar("Error", "Something went wrong. Try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff080618),
      appBar:
          AppBar(title: Text("Reset Password"), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField("Enter Your Email", emailController),
            SizedBox(height: 20),
            CustomButton(
              onPress: _resetPassword,
              text: "Send Reset Link",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.black54,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

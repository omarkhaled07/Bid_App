import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController newEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changeEmail() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "User is not logged in",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      String newEmail = newEmailController.text.trim();
      String password = passwordController.text.trim();
      if (newEmail.isEmpty || password.isEmpty) {
        Get.snackbar("Error", "Please enter all fields",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // إعادة تسجيل الدخول للتحقق من كلمة المرور
      AuthCredential credential =
          EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);

      // إرسال إيميل تحقق للبريد الجديد
      await user.verifyBeforeUpdateEmail(newEmail);
      Get.snackbar("Success",
          "Verification email sent! Please verify your new email before changing.",
          backgroundColor: Colors.green, colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      print("\u274C Firebase Error: \${e.code} - \${e.message}");
      String errorMessage = "Failed to change email.";

      switch (e.code) {
        case 'wrong-password':
          errorMessage = "Incorrect password.";
          break;
        case 'email-already-in-use':
          errorMessage = "This email is already in use.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email format.";
          break;
        case 'requires-recent-login':
          errorMessage = "Please log in again and try updating your email.";
          break;
        case 'operation-not-allowed':
          errorMessage =
              "Changing email is not allowed. Enable Email/Password sign-in in Firebase settings.";
          break;
      }

      Get.snackbar("Error", errorMessage,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      print("\u274C Unexpected Error: \$e");
      Get.snackbar("Error", "Something went wrong. Try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff080618),
      appBar: AppBar(
          title: const Text("Change Email"), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField("New Email", newEmailController),
            _buildTextField("Current Password", passwordController,
                isPassword: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _changeEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Change Email",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.black54,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

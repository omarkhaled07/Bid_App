import 'package:bid/features/presonalization/screens/changePasswordScreen/change_password.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/auth_view_model.dart';
import '../SignUp/sign_up_screen.dart';
import '../../models/auth_model.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AuthViewModel controller = Get.find();

    return Scaffold(
      backgroundColor: Color(0xff080618),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xff080618),
      ),
      body: SingleChildScrollView(
        // ✅ حل مشكلة الـ Overflow
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: EdgeInsets.only(top: 50, right: 20, left: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  txtAlign: TextAlign.left,
                  txt: "Welcome Back,",
                  txtColor: Colors.white,
                  txtsize: 32,
                ),
                CustomTextWidget(
                  txtAlign: TextAlign.left,
                  txt: "Log In!",
                  txtColor: Colors.white,
                  txtsize: 48,
                ),
                SizedBox(height: 100),
                CustomTxtFormField(
                  controller: emailController,
                  hint: "Email",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomTxtFormField(
                  controller: passwordController,
                  hint: "Password",
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Get.to(ChangePasswordScreen());
                  },
                  child: CustomTextWidget(
                    txtAlign: TextAlign.right,
                    txt: "Forget Password?",
                    txtColor: Colors.white,
                    txtsize: 12,
                  ),
                ),
                SizedBox(height: 30),
                CustomButton(
                  onPress: () {
                    if (_formKey.currentState!.validate()) {
                      controller.signInWithEmailAndPassword(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                    }
                  },
                  color: Color(0xffFFE70C),
                  text: "Log In",
                ),
                SizedBox(height: 20),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Don't have an account?  ",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Lato",
                          color: Colors.white),
                      children: [
                        TextSpan(
                          text: "Create Here",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Lato",
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(SignUpScreen());
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                    height: 20), // ✅ أضفت مسافة لتجنب الالتصاق بأسفل الشاشة
              ],
            ),
          ),
        ),
      ),
    );
  }
}

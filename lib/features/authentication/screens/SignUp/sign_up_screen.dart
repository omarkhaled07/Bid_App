import 'package:bid/features/authentication/models/auth_model.dart';
import 'package:bid/features/authentication/screens/Login/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/auth_view_model.dart';
import 'country_codes.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthViewModel controller = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final RxString selectedCountryCode = "+20".obs;
  final RxString selectedCountryName = "Egypt".obs;
  final RxString userType = 'Seller'.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff080618),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xff080618),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: EdgeInsets.only(top: 50, right: 20, left: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                    txt: "Hello,",
                    txtsize: 32,
                    txtColor: Colors.white,
                    txtAlign: TextAlign.left),
                CustomTextWidget(
                    txt: "Sign up!",
                    txtsize: 48,
                    txtColor: Colors.white,
                    txtAlign: TextAlign.left),
                SizedBox(height: 100),
                CustomTxtFormField(
                  controller: nameController,
                  hint: "UserName",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your User Name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                CustomTxtFormField(
                  controller: emailController,
                  hint: "Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    // اختيار كود الدولة (يظهر فقط الكود بدون اسم الدولة)
                    Expanded(
                      flex: 2,
                      child: Obx(() => DropdownButtonFormField<String>(
                            initialValue: selectedCountryCode.value,
                            items: countryCodes.map((country) {
                              return DropdownMenuItem(
                                value: country["code"],
                                child: Text(country["code"]!,
                                    style: TextStyle(
                                        fontSize: 14)), // عرض الكود فقط
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedCountryCode.value = value;
                              }
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xff080618), // نفس لون الخلفية
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 10),
                            ),
                            dropdownColor: Color(0xff080618), // لون القائمة
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.white, size: 18),
                          )),
                    ),
                    SizedBox(width: 10),

                    // إدخال رقم الهاتف
                    Expanded(
                      flex: 2,
                      child: CustomTxtFormField(
                        controller: phoneController,
                        hint: "Phone Number",
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your phone number";
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return "Phone number must contain only digits";
                          }
                          if (value.length < 8 || value.length > 12) {
                            return "Invalid phone number length";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: userType.value,
                    items: ['Seller', 'Buyer']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type,
                                  style: TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        userType.value = value;
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xff080618), // نفس لون الخلفية
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                    dropdownColor: Color(0xff080618), // لون القائمة
                    icon: Icon(Icons.arrow_drop_down,
                        color: Colors.white, size: 18),
                  ),
                ),
                SizedBox(height: 10),
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
                SizedBox(height: 10),
                CustomButton(
                  onPress: () {
                    if (_formKey.currentState!.validate()) {
                      controller.createAccountWithEmailAndPassword(
                        nameController.text.trim(),
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        phoneController.text.trim(),
                        userType.value.trim(),
                        selectedCountryCode.value.trim(),
                        selectedCountryName.value.trim(),
                      );
                    }
                  },
                  color: Color(0xffFFE70C),
                  text: "Register",
                ),
                SizedBox(height: 10),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Back",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Lato",
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(LoginScreen());
                        },
                      children: [
                        TextSpan(
                          text: " to Log In  ",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Lato",
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

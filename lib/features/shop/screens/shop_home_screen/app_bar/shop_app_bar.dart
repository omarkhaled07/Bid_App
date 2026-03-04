import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../authentication/controllers/auth_controller.dart';
import '../../../../authentication/screens/Login/login_screen.dart';
import '../../../../presonalization/screens/ProfileScreen/profile_screen.dart';
import '../../search_screen/search_screen.dart';

class ShopAppBarWidget extends StatelessWidget {
  final AuthController authController =
      Get.put(AuthController()); // تهيئة الـ Controller

  ShopAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xff1C162E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Get.to(() => const SearchScreen()),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "What are you looking for?",
                        style:
                            TextStyle(color: Color(0xffA9A9A9), fontSize: 16),
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.to(() => const SearchScreen()),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.search, color: Colors.teal, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => GestureDetector(
              onTap: () {
                if (authController.isLoggedIn.value) {
                  Get.to(() => ProfileScreen());
                } else {
                  Get.to(() => LoginScreen());
                }
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xff6409C2), width: 2),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: authController.userData['profileImage'] !=
                              null &&
                          authController.userData['profileImage'].isNotEmpty
                      ? NetworkImage(authController.userData['profileImage'])
                      : const NetworkImage('https://via.placeholder.com/150'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


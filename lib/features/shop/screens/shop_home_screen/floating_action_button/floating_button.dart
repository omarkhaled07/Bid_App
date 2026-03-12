import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../authentication/models/auth_view_model.dart';
import '../../add_product_screen.dart';

class FloatingBTN extends StatelessWidget {
  const FloatingBTN({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AuthViewModel authViewModel = Get.find<AuthViewModel>();

    return FloatingActionButton(
      onPressed: () {
        if (authViewModel.isGuestMode.value || authViewModel.user == null) {
          Get.snackbar(
            "Sign in required",
            "Guest users can browse only. Please sign in to add products.",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        Get.to(() => AddProductScreen(), fullscreenDialog: true);
      },
      backgroundColor: Color(0xffFFE70C),
      foregroundColor: Color(0xff464646),
      shape: CircleBorder(),
      elevation: 6,
      child: const Icon(Icons.add, size: 36),
    );
  }
}

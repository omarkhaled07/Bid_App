import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../add_product_screen.dart';

class FloatingBTN extends StatelessWidget {
  const FloatingBTN({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Get.to(() => AddProductScreen(), fullscreenDialog: true),
      backgroundColor: Color(0xffFFE70C),
      foregroundColor: Color(0xff464646),
      shape: CircleBorder(),
      elevation: 6,
      child: const Icon(Icons.add, size: 36),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'saved_addresses_screen.dart'; // تأكد من استيراد الصفحة الرئيسية

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _addAddress() async {
    if (cityController.text.isEmpty ||
        countryController.text.isEmpty ||
        addressController.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('addresses').add({
        'uid': uid,
        'country': countryController.text, // ✅ تم تصحيح الحقل
        'city': cityController.text, // ✅ المدينة تُحفظ الآن بشكل صحيح
        'address': addressController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Address added successfully",
          backgroundColor: Colors.green, colorText: Colors.white);

      // انتظار قليل لضمان عرض الرسالة قبل الرجوع
      await Future.delayed(Duration(milliseconds: 500));

      // الرجوع إلى صفحة العناوين وإعادة تحميلها
      Get.off(() => SavedAddressesScreen());
    } catch (e) {
      Get.snackbar("Error", "Failed to add address: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Address")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
                controller: countryController, // ✅ تصحيح استخدام المتحكم الصحيح
                decoration: InputDecoration(labelText: "Country")),
            SizedBox(height: 20),
            TextField(
                controller: cityController, // ✅ استخدام `cityController` الصحيح
                decoration: InputDecoration(labelText: "City")),
            SizedBox(height: 20),
            TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: "Address In Detail")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                minimumSize: Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Save Address",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

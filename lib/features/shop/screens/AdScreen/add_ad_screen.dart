import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../controllers/ad_controller.dart';
import '../../models/ad_model.dart';
import '../PaymentScreen/payment_screen.dart';

class AddAdScreen extends StatelessWidget {
  final AdController adController = Get.find();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _adUrlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final String apiKey = "8b76fe22c80007a299747564ceed8f8a";

  final Rx<File?> _imageFile = Rx<File?>(null);
  final RxString _imageUrl = "".obs;

  AddAdScreen({super.key});

  Future<String?> _uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey"),
    );
    request.files.add(await http.MultipartFile.fromPath("image", imageFile.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonData = json.decode(responseData);

    if (jsonData["success"] == true) {
      return jsonData["data"]["url"];
    }
    return null;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile.value = File(pickedFile.path);
      _imageUrl.value = "Uploading...";

      String? imageUrl = await _uploadImage(_imageFile.value!);
      if (imageUrl != null) {
        _imageUrl.value = imageUrl;
      } else {
        _imageUrl.value = "Failed to upload image";
      }
    }
  }

  double _calculateCost(int days) {
    return days * 50.0;
  }

  Future<String?> _fetchPaymobApiKey() async {
    try {
      DocumentSnapshot paymentSettings =
      await FirebaseFirestore.instance.collection('payment_settings').doc('keys').get();
      if (paymentSettings.exists) {
        return paymentSettings['PaymobApiKey'] as String?;
      }
    } catch (e) {
      print("Error fetching Paymob API key: $e");
    }
    return null;
  }

  Future<void> _proceedToPayment(BuildContext context, int duration) async {
    double amount = _calculateCost(duration);
    String? paymentKey = await _fetchPaymobApiKey();
    if (paymentKey == null) {
      Get.snackbar(
        "Error",
        "Failed to fetch payment key",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    List<String> productIds = [];

    bool? paymentSuccess = await Get.to(() => PaymentScreen(
      amount: amount,
      paymentKey: paymentKey,
      productIds: productIds,
    ));

    if (paymentSuccess == true) {
      final newAd = Ad(
        id: "",
        imageUrl: _imageUrl.value,
        title: _titleController.text,
        description: _descriptionController.text,
        duration: duration,
        cost: amount,
        adUrl: _adUrlController.text,
        timestamp: Timestamp.now(),
      );
      await adController.addAd(newAd);
      Get.back();
    } else {
      Get.snackbar("Payment Failed", "Ad was not added due to payment failure",
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Ad"),
        backgroundColor: Color(0xff080618),
      ),
      backgroundColor: Color(0xff080618),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_titleController, "Title"),
                SizedBox(height: 20),
                _buildTextField(_descriptionController, "Description"),
                SizedBox(height: 20),
                _buildTextField(_durationController, "Duration (days)", isNumber: true),
                SizedBox(height: 20),
                _buildTextField(_adUrlController, "Ad URL"),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Obx(() => Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white),
                    ),
                    child: _imageFile.value == null
                        ? Center(child: Text("Tap to add an image", style: TextStyle(color: Colors.white)))
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _imageFile.value!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                  )),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_imageUrl.value.isEmpty || _imageUrl.value == "Uploading...") {
                        Get.snackbar("Error", "Please wait for the image to upload!", backgroundColor: Colors.red);
                        return;
                      }

                      int duration = int.parse(_durationController.text);
                      await _proceedToPayment(context, duration);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffFFE70C),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    "Proceed to Payment",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter $label";
        }
        if (isNumber && (int.tryParse(value) == null || int.parse(value) <= 0)) {
          return "Enter a valid number";
        }
        return null;
      },
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import '../../../authentication/models/auth_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  var userData = {}.obs;
  File? _imageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();

    if (userDoc.exists) {
      userData.value = userDoc.data() as Map<String, dynamic>;

      setState(() {
        nameController.text = userData['name'] ?? "";
        phoneController.text = userData['phone'] ?? "";
        emailController.text = userData['email'] ?? "";
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImageToImgbb(File imageFile) async {
    try {
      String apiKey =
          "8b76fe22c80007a299747564ceed8f8a"; // مفتاح Imgbb الخاص بك
      var url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

      var request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return jsonResponse['data']['url']; // رابط الصورة المرفوعة
      } else {
        print("❌ Error uploading image: ${jsonResponse['error']}");
        return null;
      }
    } catch (e) {
      print("❌ Exception while uploading image: $e");
      return null;
    }
  }

  Future<void> saveProfileChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      String uid = _auth.currentUser!.uid;
      String? imageUrl;

      // رفع الصورة إذا تم اختيارها
      if (_imageFile != null) {
        imageUrl = await uploadImageToImgbb(_imageFile!);
      }

      // تحديث البيانات في Firestore
      await _firestore.collection('users').doc(uid).update({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        if (imageUrl != null)
          "profileImage": imageUrl, // تحديث الصورة إذا تم رفعها
      });

      Get.back();
      Get.snackbar("Success", "Profile updated successfully",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff080618),
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (userData.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : NetworkImage(userData['profileImage'] ?? "")
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(nameController, "Full Name", Icons.person),
              _buildTextField(phoneController, "Phone Number", Icons.phone),
              _buildTextField(emailController, "Email", Icons.email,
                  enabled: false),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : CustomButton(
                      text: "Save Changes",
                      onPress: saveProfileChanges,
                    ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.white),
          filled: true,
          fillColor: Color(0xff1c1b2a),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          labelStyle: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

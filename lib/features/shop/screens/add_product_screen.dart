import 'dart:convert';
import 'dart:io';
import 'package:bid/features/shop/screens/shop_home_screen/shop_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../utils/constants/api_constants.dart';
import '../services/paymob_service.dart';
import 'PaymentScreen/payment_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController startingPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController bidIncrementController = TextEditingController();

  String condition = 'New';
  String auctionDuration = '1 Day';
  String category = 'Bags';
  File? image;
  bool imageError = false;
  bool isAuction = false;
  bool isPromoted = false;
  int? promotionDays;
  double promotionCost = 0.0;

  final List<String> categories = [
    'Bags',
    'Accessories',
    'Shoes',
    'Jewelry',
    'Watches',
    'Fashion'
  ];
  final List<String> conditions = ['New', 'Used'];
  final List<String> durations = [
    '1 Day',
    '2 Days',
    '3 Days',
    '7 Days',
    '14 Days'
  ];

  final List<int> promotionDaysOptions = [1, 3, 7, 14, 30];

  final PaymobService _paymobService =
  PaymobService(apiKey: APIKey.PaymobApiKey);

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        imageError = false;
      });
    }
  }

  Future<void> submitForm() async {
    if (image == null) {
      setState(() {
        imageError = true;
      });
      return;
    }

    if (isPromoted && promotionDays == null) {
      showErrorDialog("Please select the number of promotion days.");
      return;
    }

    print("Starting submitForm...");
    showLoadingDialog();

    try {
      String imageUrl = await uploadImageToImgBB(image!);

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No user is logged in!");
        Navigator.pop(context);
        return;
      }

      String userId = user.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print("❌ User document not found in Firestore!");
        Navigator.pop(context);
        return;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String seller = userData['name'] ?? "Unknown User";
      String sellerImage = userData['profileImage'] ?? "";
      String sellerAddress = userData['email'] ?? "No mail";

      bool shouldUploadProduct = !isPromoted;
      print("Initial shouldUploadProduct: $shouldUploadProduct");

      if (isPromoted && promotionDays != null) {
        print("Initiating payment for promoted product...");
        bool? paymentSuccess = await _initiatePayment(promotionCost);
        print("Payment Success Result: $paymentSuccess");
        if (paymentSuccess == null || !paymentSuccess) {
          shouldUploadProduct = false;
          print(
              "Payment failed or canceled, shouldUploadProduct set to: $shouldUploadProduct");
          Navigator.pop(context);
          showErrorDialog(
              "Payment failed or was canceled. Product not uploaded.");
        } else {
          shouldUploadProduct = true;
          print(
              "Payment succeeded, shouldUploadProduct set to: $shouldUploadProduct");
        }
      }

      if (!shouldUploadProduct) {
        Navigator.pop(context);
        print("Product upload skipped due to payment failure or cancellation.");
        return;
      }

      print("Uploading product to Firestore...");
      await FirebaseFirestore.instance.collection('products').add({
        'title': titleController.text,
        'description': descriptionController.text,
        'category': category,
        'condition': condition,
        'imageUrl': imageUrl,
        'sellerImage': sellerImage,
        'sellerAddress': sellerAddress,
        'isAuction': isAuction,
        'isPromoted': isPromoted,
        'promotionDays': isPromoted ? promotionDays : null,
        'startPrice':
        isAuction ? double.tryParse(startingPriceController.text) ?? 0 : 0,
        'bidIncrement':
        isAuction ? double.tryParse(bidIncrementController.text) ?? 0 : 0,
        'maxPrice': isAuction
            ? double.tryParse(startingPriceController.text) ?? 0
            : double.tryParse(maxPriceController.text) ?? 0,
        'auctionDuration': isAuction ? auctionDuration : '',
        'seller': seller,
        'sellerId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'endTime': isAuction ? calculateEndTime(auctionDuration) : null,
        'status': "On Going",
      });

      print("Product uploaded successfully!");
      Navigator.pop(context);
      showSuccessDialog();
      Get.to(() => ShopHomeScreen());
    } catch (e) {
      Navigator.pop(context);
      print("❌ Error adding product: $e");
      showErrorDialog("An error occurred. Please try again.");
    }
  }

  Future<bool?> _initiatePayment(double amount) async {
    try {
      print("Starting payment process...");
      String? authToken = await _paymobService.getAuthToken();
      if (authToken == null) {
        Get.snackbar("Error", "Failed to get auth token");
        print("Failed to get auth token.");
        return false;
      }
      print("Auth Token: $authToken");

      int amountCents = (amount * 100).toInt();
      int? orderId = await _paymobService.createOrder(
        authToken: authToken,
        amountCents: amountCents,
      );
      if (orderId == null) {
        Get.snackbar("Error", "Failed to create order");
        print("Failed to create order.");
        return false;
      }
      print("Order ID: $orderId");

      User? user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String billingName = userData['name'] ?? "Unknown User";
      String billingEmail = userData['email'] ?? "user@example.com";
      String billingPhone = userData['phone'] ?? "01012345678";
      int integrationId = APIKey.PaymobIntegrationId;

      String? paymentKey = await _paymobService.getPaymentKey(
        authToken: authToken,
        orderId: orderId,
        amountCents: amountCents,
        billingName: billingName,
        billingEmail: billingEmail,
        billingPhone: billingPhone,
        integrationId: integrationId,
      );
      if (paymentKey == null) {
        Get.snackbar("Error", "Failed to get payment key");
        print("Failed to get payment key.");
        return false;
      }
      print("Payment Key: $paymentKey");

      bool? paymentSuccess = await Get.to(
            () => PaymentScreen(
          amount: amount,
          paymentKey: paymentKey,
          productIds: [],
        ),
      );

      print("Payment Result from PaymentScreen: $paymentSuccess");
      return paymentSuccess;
    } catch (e) {
      print("❌ Error during payment: $e");
      return false;
    }
  }

  // ... (keep all your existing widget methods like _buildImagePicker, _buildTextField, etc.)
  // ... (keep all your existing helper methods like uploadImageToImgBB, showLoadingDialog, etc.)
  // ... (keep your existing calculateEndTime method)
  Future<String> uploadImageToImgBB(File imageFile) async {
    try {
      String imgBBApiKey = "8b76fe22c80007a299747564ceed8f8a";
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$imgBBApiKey'),
      );

      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (jsonResponse['success']) {
        return jsonResponse['data']['url'];
      } else {
        throw Exception(
            "Failed to upload image: ${jsonResponse['error']['message']}");
      }
    } catch (e) {
      print("❌ Error uploading image: $e");
      throw Exception("Image upload failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text("Add New Product",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            _buildTextField(titleController, "Product Title", required: true),
            _buildTextField(descriptionController, "Description",
                isMultiLine: true),
            _buildDropdown("Condition", conditions, condition,
                    (newValue) => setState(() => condition = newValue!)),
            _buildDropdown("Category", categories, category,
                    (newValue) => setState(() => category = newValue!)),
            SwitchListTile(
              title: const Text("Is this product an auction?"),
              value: isAuction,
              onChanged: (value) => setState(() => isAuction = value),
            ),
            if (isAuction) ...[
              _buildTextField(startingPriceController, "Starting Price",
                  isNumber: true),
              _buildTextField(bidIncrementController, "Minimum Bid Increment",
                  isNumber: true),
              SizedBox(height: 10),
              _buildDropdown("Auction Duration", durations, auctionDuration,
                      (newValue) => setState(() => auctionDuration = newValue!)),
            ] else ...[
              _buildTextField(maxPriceController, "Max Price", isNumber: true),
            ],
            SwitchListTile(
              title: const Text("Do you want to promote this product?"),
              value: isPromoted,
              onChanged: (value) => setState(() {
                isPromoted = value;
                if (!value) {
                  promotionDays = null;
                  promotionCost = 0.0;
                }
              }),
            ),
            if (isPromoted) ...[
              const SizedBox(height: 20),
              const Text("Promotion Duration (Days)",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 10),
              _buildDropdown(
                "Select Promotion Days",
                promotionDaysOptions.map((days) => "$days days").toList(),
                promotionDays != null ? "$promotionDays days" : null,
                    (newValue) {
                  setState(() {
                    promotionDays =
                        int.parse(newValue!.replaceAll(" days", ""));
                    promotionCost = promotionDays! * 10.0;
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                "Total Cost: \$${promotionCost.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text("Add Product",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upload Image *",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 5),
        Center(
          child: GestureDetector(
            onTap: () => pickImage(ImageSource.gallery),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: imageError ? Colors.red : Colors.grey[300],
              backgroundImage: image != null ? FileImage(image!) : null,
              child: image == null
                  ? const Icon(Icons.camera_alt, size: 40, color: Colors.black)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white10,
        ),
        dropdownColor: Colors.grey[900],
        style: const TextStyle(color: Colors.white),
        value: selectedValue,
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isMultiLine = false,
        bool required = false,
        bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: isMultiLine ? 4 : 1,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white10,
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: Colors.blueAccent),
              SizedBox(width: 20),
              Text("Uploading product...",
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text("Success",
              style:
              TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          content: const Text("Product added successfully!",
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Get.offAll(() => ShopHomeScreen());
              },
              child:
              const Text("OK", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text("Error",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(message, style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
              const Text("OK", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  Timestamp? calculateEndTime(String duration) {
    final now = DateTime.now();
    int daysToAdd = 1;

    if (duration.contains("2 Days")) {
      daysToAdd = 2;
    } else if (duration.contains("3 Days")) {
      daysToAdd = 3;
    } else if (duration.contains("7 Days")) {
      daysToAdd = 7;
    } else if (duration.contains("14 Days")) {
      daysToAdd = 14;
    }

    final endTime = now.add(Duration(days: daysToAdd));
    return Timestamp.fromDate(endTime);
  }
}

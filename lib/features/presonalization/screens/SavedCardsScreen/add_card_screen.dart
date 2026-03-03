import 'package:bid/features/presonalization/screens/SavedCardsScreen/saved_cards.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  late String uid;
  String cardNumber = '';
  String cardholderName = '';
  String expiryDate = '';
  String cvv = '';

  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser!.uid;
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) {
      return; // إذا كانت هناك أخطاء، لا تستمر بالحفظ
    }

    try {
      // ✅ التأكد من أن المستخدم مسجل الدخول
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar("Error", "You must be logged in to save a card",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      await _firestore.collection('cards').add({
        'uid': user.uid,
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'expiryDate': expiryDate,
        'last4': cardNumber.substring(cardNumber.length - 4),
        'timestamp': FieldValue.serverTimestamp(), // ✅ إضافة توقيت الحفظ
      });

      Get.snackbar("Success", "Card saved successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);

      await Future.delayed(Duration(milliseconds: 500));
      Get.off(() => SavedCardsScreen());
    } catch (e) {
      Get.snackbar("Error", "Failed to save card: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff080618),
      appBar: AppBar(title: Text("Saved Cards"), backgroundColor: Colors.black),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Card Number",
                    filled: true,
                    fillColor: Colors.white10),
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Enter card number";
                  if (!RegExp(r'^\d{16}$').hasMatch(value.trim()))
                    return "Enter a valid 16-digit card number";
                  return null;
                },
                onChanged: (value) => cardNumber = value,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Cardholder Name",
                    filled: true,
                    fillColor: Colors.white10),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Enter cardholder name";
                  if (!RegExp(r'^[a-zA-Z\u0600-\u06FF ]+$')
                      .hasMatch(value.trim())) return "Enter a valid name";
                  return null;
                },
                onChanged: (value) => cardholderName = value,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Expiry Date (MM/YY)",
                    filled: true,
                    fillColor: Colors.white10),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Enter expiry date";

                  // التحقق من الصيغة MM/YY
                  RegExp regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                  if (!regex.hasMatch(value.trim()))
                    return "Enter valid MM/YY format";

                  // استخراج الشهر والسنة
                  List<String> parts = value.split('/');
                  int month = int.parse(parts[0]);
                  int year = int.parse(parts[1]) + 2000; // تحويل YY إلى YYYY

                  // الحصول على السنة الحالية والشهر الحالي
                  DateTime now = DateTime.now();
                  int currentYear = now.year;
                  int currentMonth = now.month;

                  // التحقق من أن البطاقة لم تنتهِ صلاحيتها
                  if (year < currentYear ||
                      (year == currentYear && month < currentMonth)) {
                    return "Card has expired";
                  }

                  return null;
                },
                onChanged: (value) => expiryDate = value,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                    labelText: "CVV", filled: true, fillColor: Colors.white10),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true, // ✅ إخفاء الـ CVV عند الإدخال
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter CVV";
                  if (!RegExp(r'^\d{3,4}$').hasMatch(value.trim()))
                    return "Enter valid CVV";
                  return null;
                },
                onChanged: (value) => cvv = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellowAccent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save Card",
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
      ),
    );
  }
}

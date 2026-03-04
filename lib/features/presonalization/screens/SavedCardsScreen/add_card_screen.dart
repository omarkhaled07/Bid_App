import 'package:bid/features/presonalization/screens/SavedCardsScreen/saved_cards.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
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
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'You must be logged in to save a card',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      await _firestore.collection('cards').add({
        'uid': user.uid,
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'expiryDate': expiryDate,
        'last4': cardNumber.substring(cardNumber.length - 4),
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Card saved successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.off(() => const SavedCardsScreen());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save card: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff080618),
      appBar: AppBar(
        title: const Text('Saved Cards'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  filled: true,
                  fillColor: Colors.white10,
                ),
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter card number';
                  }
                  if (!RegExp(r'^\d{16}$').hasMatch(value.trim())) {
                    return 'Enter a valid 16-digit card number';
                  }
                  return null;
                },
                onChanged: (value) => cardNumber = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  filled: true,
                  fillColor: Colors.white10,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter cardholder name';
                  }
                  if (!RegExp(r'^[a-zA-Z\u0600-\u06FF ]+$')
                      .hasMatch(value.trim())) {
                    return 'Enter a valid name';
                  }
                  return null;
                },
                onChanged: (value) => cardholderName = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Expiry Date (MM/YY)',
                  filled: true,
                  fillColor: Colors.white10,
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter expiry date';
                  }

                  final RegExp regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                  if (!regex.hasMatch(value.trim())) {
                    return 'Enter valid MM/YY format';
                  }

                  final List<String> parts = value.split('/');
                  final int month = int.parse(parts[0]);
                  final int year = int.parse(parts[1]) + 2000;

                  final DateTime now = DateTime.now();
                  final int currentYear = now.year;
                  final int currentMonth = now.month;

                  if (year < currentYear ||
                      (year == currentYear && month < currentMonth)) {
                    return 'Card has expired';
                  }

                  return null;
                },
                onChanged: (value) => expiryDate = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  filled: true,
                  fillColor: Colors.white10,
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter CVV';
                  }
                  if (!RegExp(r'^\d{3,4}$').hasMatch(value.trim())) {
                    return 'Enter valid CVV';
                  }
                  return null;
                },
                onChanged: (value) => cvv = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellowAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Card',
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

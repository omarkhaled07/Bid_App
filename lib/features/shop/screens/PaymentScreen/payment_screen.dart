import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'payment_web_view.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String paymentKey;
  final List<String> productIds;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.paymentKey,
    required this.productIds,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final RxBool _isProcessing = false.obs;
  final RxInt _selectedPaymentMethod = 0.obs;
  String? _clientId;
  String? _secretKey;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPaymentSettings();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _nameController.text = userDoc['name'] ?? '';
            _emailController.text = userDoc['email'] ?? '';
            _phoneController.text = userDoc['phone'] ?? '';
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _loadPaymentSettings() async {
    try {
      DocumentSnapshot paymentSettings = await FirebaseFirestore.instance
          .collection('payment_settings')
          .doc('keys')
          .get();
      if (paymentSettings.exists) {
        setState(() {
          _clientId = paymentSettings['clientId'] as String?;
          _secretKey = paymentSettings['secretKey'] as String?;
        });
      }
    } catch (e) {
      print("Error loading payment settings: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payment - \$${widget.amount.toStringAsFixed(2)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isProcessing.value
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.deepPurple.shade50,
                    Colors.deepPurple.shade100,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPaymentSummaryCard(),
                      const SizedBox(height: 20),
                      _buildPaymentMethodSelector(),
                      const SizedBox(height: 20),
                      _buildPaymentFormCard(),
                      const SizedBox(height: 30),
                      _buildPayButton(context),
                      const SizedBox(height: 15),
                      const Text(
                        "Your data is securely protected and not stored with us",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            _buildSummaryRow(
                "Subtotal", "\$${widget.amount.toStringAsFixed(2)}"),
            const Divider(),
            _buildSummaryRow(
              "Total",
              "\$${widget.amount.toStringAsFixed(2)}",
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isTotal ? Colors.deepPurple : Colors.grey.shade700,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Method",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentMethodCard(
                    index: 0,
                    icon: Icons.credit_card,
                    title: "Credit Card",
                    subtitle: "Pay with Visa/Mastercard",
                    isSelected: _selectedPaymentMethod.value == 0,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPaymentMethodCard(
                    index: 1,
                    icon: Icons.payment,
                    title: "PayPal",
                    subtitle: "Pay with PayPal account",
                    isSelected: _selectedPaymentMethod.value == 1,
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildPaymentMethodCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectedPaymentMethod.value = index,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.deepPurple : Colors.grey,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.deepPurple.shade400 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentFormCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Billing Information",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextFormField(
              controller: _nameController,
              icon: Icons.person_outline,
              label: "Full Name",
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            _buildTextFormField(
              controller: _emailController,
              icon: Icons.email_outlined,
              label: "Email Address",
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!GetUtils.isEmail(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            _buildTextFormField(
              controller: _phoneController,
              icon: Icons.phone_outlined,
              label: "Phone Number",
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      style: const TextStyle(fontSize: 16),
      validator: validator,
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Obx(() => ElevatedButton(
          onPressed:
              _isProcessing.value ? null : () => _validateAndPay(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
          child: _isProcessing.value
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedPaymentMethod.value == 0
                          ? Icons.credit_card
                          : Icons.payment,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Proceed to Payment",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ));
  }

  Future<bool> _processPayPalPayment(BuildContext context) async {
    if (_clientId == null || _secretKey == null) {
      Get.snackbar(
        "Error",
        "Failed to load PayPal credentials",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      _isProcessing.value = true;
      Get.snackbar(
        "Processing",
        "Redirecting to PayPal...",
        snackPosition: SnackPosition.BOTTOM,
      );

      final paymentData = {
        "amount": widget.amount.toStringAsFixed(2),
        "currency": "USD",
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "productIds": widget.productIds,
      };

      bool success = false;

      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text("Confirm PayPal Payment"),
          content: Text(
              "You will be redirected to PayPal to complete your payment of \$${widget.amount.toStringAsFixed(2)}"),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text("Continue to PayPal"),
            ),
          ],
        ),
      );

      if (confirm != true) {
        _isProcessing.value = false;
        return false;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => PaypalCheckoutView(
            sandboxMode: true,
            clientId: _clientId!,
            secretKey: _secretKey!,
            transactions: [
              {
                "amount": {
                  "total": widget.amount.toStringAsFixed(2),
                  "currency": "USD",
                  "details": {
                    "subtotal": widget.amount.toStringAsFixed(2),
                    "shipping": "0",
                    "shipping_discount": "0"
                  }
                },
                "description": "Payment for products",
                "item_list": {
                  "items": widget.productIds
                      .map((id) => {
                            "name": "Product $id",
                            "quantity": 1,
                            "price": (widget.amount / widget.productIds.length)
                                .toStringAsFixed(2),
                            "currency": "USD"
                          })
                      .toList(),
                }
              }
            ],
            note: "Thank you for your purchase",
            onSuccess: (Map params) async {
              success = true;
              await _savePaymentToFirestore(paymentData, true);
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            onError: (error) {
              success = false;
              if (context.mounted) {
                Navigator.pop(context, false);
              }
            },
            onCancel: () {
              success = false;
              if (context.mounted) {
                Navigator.pop(context, false);
              }
            },
          ),
        ),
      );

      return success;
    } catch (e) {
      print("PayPal Error: $e");
      Get.snackbar(
        "PayPal Error",
        "An error occurred while connecting to PayPal",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<void> _savePaymentToFirestore(
      Map<String, dynamic> paymentData, bool isPayPal) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('payments').add({
          ...paymentData,
          'userId': user.uid,
          'paymentMethod': isPayPal ? 'PayPal' : 'Paymob',
          'status': 'completed',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error saving payment: $e");
    }
  }

  Future<void> _validateAndPay(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        "Validation Error",
        "Please fill all required fields correctly",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (widget.amount <= 0) {
      Get.snackbar(
        "Error",
        "Invalid payment amount",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Confirm Payment"),
        content: Text(
            "You are about to pay \$${widget.amount.toStringAsFixed(2)}. Do you want to proceed?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Proceed", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    _isProcessing.value = true;

    try {
      final paymentData = {
        'amount': widget.amount,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'paymentKey': widget.paymentKey,
        'productIds': widget.productIds,
      };

      bool? paymentSuccess;

      if (_selectedPaymentMethod.value == 0) {
        DocumentSnapshot paymentSettings = await FirebaseFirestore.instance
            .collection('payment_settings')
            .doc('keys')
            .get();
        if (!paymentSettings.exists ||
            paymentSettings['PaymobIframeId'] == null) {
          Get.snackbar(
            "Error",
            "Failed to load Paymob settings",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          _isProcessing.value = false;
          return;
        }
        final paymentUrl =
            "https://accept.paymob.com/api/acceptance/iframes/${paymentSettings['PaymobIframeId']}?payment_token=${widget.paymentKey}";

        paymentSuccess = await Get.to<bool>(() => PaymentWebView(
              paymentUrl: paymentUrl,
              productIds: widget.productIds,
              paymentData: paymentData,
            ));
      } else {
        paymentSuccess = await _processPayPalPayment(context);
      }

      if (paymentSuccess == true) {
        await _savePaymentToFirestore(
            paymentData, _selectedPaymentMethod.value == 1);
        Get.snackbar(
          "Payment Successful",
          "Your payment has been processed successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } else if (paymentSuccess == false) {
        Get.snackbar(
          "Payment Failed",
          "There was an error processing your payment",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred during payment: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isProcessing.value = false;
    }
  }
}

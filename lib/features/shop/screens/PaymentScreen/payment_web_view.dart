import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final List<String> productIds;
  final Map<String, dynamic> paymentData;

  const PaymentWebView({
    super.key,
    required this.paymentUrl,
    required this.productIds,
    required this.paymentData,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;
  bool isLoading = true;
  bool hasError = false;
  bool _isHandlingResult = false;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              this.progress = progress / 100;
            });
          },
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
            _checkPaymentStatus(url);
          },
          onWebResourceError: (error) {
            setState(() {
              isLoading = false;
              hasError = true;
            });
            _showError("حدث خطأ أثناء تحميل صفحة الدفع");
          },
          onUrlChange: (urlChange) {
            _checkPaymentStatus(urlChange.url ?? '');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentStatus(String url) {
    debugPrint('Checking payment status with URL: $url');
    if (_isHandlingResult) {
      return;
    }

    final uri = Uri.tryParse(url);
    final successParam = uri?.queryParameters['success']?.toLowerCase();
    final pendingParam = uri?.queryParameters['pending']?.toLowerCase();
    final responseCode = uri?.queryParameters['txn_response_code']?.toLowerCase();

    final isSuccess = url.contains('success') ||
        successParam == 'true' ||
        responseCode == 'approved' ||
        responseCode == 'accept';
    final isFailure = url.contains('fail') ||
        url.contains('error') ||
        url.contains('declined') ||
        url.contains('rejected') ||
        successParam == 'false' ||
        pendingParam == 'false';

    if (isSuccess) {
      _isHandlingResult = true;
      _handleSuccessfulPayment();
    } else if (isFailure) {
      _isHandlingResult = true;
      Navigator.pop(context, false);
    }
  }

  Future<void> _handleSuccessfulPayment() async {
    try {
      await _updateProductStatusToSold();
      await _savePaymentData();

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("❌ خطأ أثناء معالجة الدفع الناجح: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("حدث خطأ أثناء معالجة الدفع: $e"),
              backgroundColor: Colors.red),
        );
      }
      Navigator.pop(context, false);
    }
  }

  Future<void> _savePaymentData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      DocumentSnapshot paymentSettings = await FirebaseFirestore.instance
          .collection('payment_settings')
          .doc('keys')
          .get();

      if (!paymentSettings.exists) {
        throw Exception("Payment settings not found");
      }

      var paymentData = {
        ...widget.paymentData,
        'userId': userId,
        'status': 'completed',
        'paymentGateway': 'Paymob',
        'integrationId': paymentSettings['PaymobIntegrationId'],
        'iframeId': paymentSettings['PaymobIframeId'],
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('payments').add(paymentData);

      debugPrint("✅ تم حفظ بيانات الدفع بنجاح");
    } catch (e) {
      debugPrint("❌ خطأ أثناء حفظ بيانات الدفع: $e");
      rethrow;
    }
  }

  Future<void> _updateProductStatusToSold() async {
    try {
      for (String productId in widget.productIds) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .update({
          'status': 'sold',
          'isSold': true,
          'soldAt': FieldValue.serverTimestamp(),
        });
      }

      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (userId.isNotEmpty) {
        for (String productId in widget.productIds) {
          QuerySnapshot cartItems = await FirebaseFirestore.instance
              .collection('carts')
              .doc(userId)
              .collection('items')
              .where('productId', isEqualTo: productId)
              .get();

          for (var doc in cartItems.docs) {
            await doc.reference.delete();
          }
        }
      }

      debugPrint("✅ تم تحديث حالة المنتجات ومسح السلة بنجاح");
    } catch (e) {
      debugPrint("❌ خطأ أثناء تحديث حالة المنتجات: $e");
      rethrow;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _clearWebViewData() async {
    await _controller.clearCache();
    await _controller.clearLocalStorage();
  }

  @override
  void dispose() {
    _clearWebViewData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _showExitConfirmation();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop(false);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "عملية الدفع",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF4A6FA5),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final shouldPop = await _showExitConfirmation();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop(false);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF4A6FA5).withValues(alpha: 0.6),
                ),
              ),
            if (hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 50, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      "فشل تحميل صفحة الدفع",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "الرجاء التحقق من اتصال الإنترنت والمحاولة مرة أخرى",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          hasError = false;
                          isLoading = true;
                        });
                        _controller.reload();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6FA5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "إعادة المحاولة",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إلغاء عملية الدفع"),
        content: const Text("هل أنت متأكد أنك تريد إلغاء عملية الدفع الحالية؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("البقاء"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("خروج", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

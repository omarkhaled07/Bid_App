import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class PaymobService {
  final Dio _dio;
  final Logger _logger;
  final String _apiKey;
  final String _baseUrl = "https://accept.paymob.com/api";

  PaymobService({
    required String apiKey,
    Dio? dio,
    Logger? logger,
  })  : _apiKey = apiKey,
        _dio = dio ?? Dio(),
        _logger = logger ?? Logger() {
    // تكوين إعدادات Dio الأساسية
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // 1️⃣ الحصول على توكن المصادقة
  Future<String?> getAuthToken() async {
    try {
      _logger.i("Requesting auth token from Paymob");

      final response = await _retryRequest(
            () => _dio.post(
          "$_baseUrl/auth/tokens",
          data: {"api_key": _apiKey},
        ),
      );

      final token = response.data["token"];
      _logger.i("Successfully received auth token");
      return token;
    } on DioException catch (e) {
      _logError("Failed to get auth token", e);
      return null;
    } catch (e) {
      _logger.e("Unexpected error getting auth token", error: e);
      return null;
    }
  }

  // 2️⃣ إنشاء طلب دفع
  Future<int?> createOrder({
    required String authToken,
    required int amountCents,
    String currency = "EGP",
  }) async {
    try {
      _validateAmount(amountCents);

      _logger.i("Creating order for amount: ${amountCents / 100} $currency");

      final response = await _retryRequest(
            () => _dio.post(
          "$_baseUrl/ecommerce/orders",
          data: {
            "auth_token": authToken,
            "delivery_needed": false,
            "amount_cents": amountCents.toString(),
            "currency": currency,
            "items": [],
          },
        ),
      );

      final orderId = response.data["id"];
      _logger.i("Order created successfully with ID: $orderId");
      return orderId;
    } on DioException catch (e) {
      _logError("Failed to create order", e);
      return null;
    } catch (e) {
      _logger.e("Unexpected error creating order", error: e);
      return null;
    }
  }

  // 3️⃣ إنشاء مفتاح الدفع
  Future<String?> getPaymentKey({
    required String authToken,
    required int orderId,
    required int amountCents,
    required String billingName,
    required String billingEmail,
    required String billingPhone,
    required int integrationId,
    String currency = "EGP",
    int expiration = 3600,
  }) async {
    try {
      _validateAmount(amountCents);
      _validateEmail(billingEmail);
      _validatePhone(billingPhone);

      _logger.i("Generating payment key for order: $orderId");

      final response = await _retryRequest(
            () => _dio.post(
          "$_baseUrl/acceptance/payment_keys",
          data: {
            "auth_token": authToken,
            "amount_cents": amountCents.toString(),
            "expiration": expiration,
            "order_id": orderId.toString(),
            "billing_data": _buildBillingData(
              billingName,
              billingEmail,
              billingPhone,
            ),
            "currency": currency,
            "integration_id": integrationId,
          },
        ),
      );

      final paymentKey = response.data["token"];
      _logger.i("Payment key generated successfully");
      return paymentKey;
    } on DioException catch (e) {
      _logError("Failed to generate payment key", e);
      return null;
    } catch (e) {
      _logger.e("Unexpected error generating payment key", error: e);
      return null;
    }
  }

  // بناء بيانات الفاتورة
  Map<String, dynamic> _buildBillingData(
      String name,
      String email,
      String phone,
      ) {
    return {
      "first_name": name.split(" ").first,
      "last_name": name.split(" ").length > 1 ? name.split(" ").last : "NA",
      "email": email,
      "phone_number": phone,
      "apartment": "NA",
      "floor": "NA",
      "street": "NA",
      "building": "NA",
      "city": "Cairo",
      "country": "EG",
      "postal_code": "NA",
      "state": "NA",
    };
  }

  // إعادة محاولة الطلب في حالة الفشل
  Future<Response> _retryRequest(Future<Response> Function() request) async {
    const maxAttempts = 3;
    DioException? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await request();
      } on DioException catch (e) {
        lastError = e;
        if (attempt < maxAttempts) {
          _logger.w("Attempt $attempt failed, retrying...");
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }

    throw lastError!;
  }

  // تسجيل الأخطاء
  void _logError(String message, DioException e) {
    _logger.e("$message: ${e.response?.data ?? e.message}", error: e);
  }

  // التحقق من صحة المبلغ
  void _validateAmount(int amountCents) {
    if (amountCents <= 0) {
      throw ArgumentError("Amount must be greater than 0");
    }
  }

  // التحقق من صحة البريد الإلكتروني
  void _validateEmail(String email) {
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw ArgumentError("Invalid email format");
    }
  }

  // التحقق من صحة رقم الهاتف
  void _validatePhone(String phone) {
    if (phone.length < 10) {
      throw ArgumentError("Phone number must be at least 10 digits");
    }
  }
}
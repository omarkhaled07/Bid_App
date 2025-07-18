import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class ProductModel {
  final String id;
  String imageUrl;
  final String title;
  final String size;
  final Color color;
  final String description;
  final double minPrice;
  final double maxPrice;
  final double startPrice;
  double currentPrice;
  final int daysLeft;
  final int views;
  final String brand;
  final String category;
  final String state;
  final bool isSold;
  bool isFavourite;
  final bool isPromoted;
  final bool isAuction;
  final String highestBidder;
  final String condition;
  final String seller;
  final String sellerId;
  final String status;
  final Timestamp? endTime; // ✅ إضافة حقل endTime

  ProductModel({
    required this.seller,
    required this.sellerId,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.size,
    required this.color,
    required this.description,
    required this.minPrice,
    required this.maxPrice,
    required this.startPrice,
    required this.currentPrice,
    required this.daysLeft,
    required this.views,
    required this.brand,
    required this.category,
    required this.state,
    required this.isSold,
    required this.isFavourite,
    required this.isPromoted,
    required this.isAuction,
    required this.highestBidder,
    required this.condition,
    required this.status,
    this.endTime, // ✅ تضمين endTime في الكونستركتور
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      size: data['size'] ?? '',
      color: Color(int.tryParse(data['color'] ?? '0xFF000000') ?? 0xFF000000),
      description: data['description'] ?? '',
      minPrice: (data['minPrice'] ?? 0).toDouble(),
      maxPrice: (data['maxPrice'] ?? 0).toDouble(),
      startPrice: (data['startPrice'] ?? 0).toDouble(),
      currentPrice: (data['currentPrice'] ?? 0).toDouble(),
      daysLeft: data['daysLeft'] ?? 0,
      views: data['views'] ?? 0,
      brand: data['brand'] ?? '',
      category: data['category'] ?? '',
      state: data['state'] ?? '',
      isSold: data['isSold'] ?? false,
      isFavourite: data['isFavourite'] ?? false,
      isPromoted: data['isPromoted'] ?? false,
      isAuction: data['isAuction'] ?? false,
      highestBidder: data['highestBidder'] ?? '',
      condition: data['condition'] ?? 'New',
      seller: data['seller'] ?? '',
      sellerId: data['sellerId'] ?? '',
      status: data['status'] ?? 'On Going',
      endTime: data['endTime'], // ✅ قراءة endTime من Firestore
    );
  }

  Future<void> updateViews() async {
    try {
      DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(id);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(productRef);
        if (!snapshot.exists) return;

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int currentViews = (data['views'] ?? 0) as int;

        transaction.update(productRef, {'views': currentViews + 1});
      });

      print("✅ تم تحديث عدد المشاهدات بنجاح!");
    } catch (e) {
      print("❌ خطأ أثناء تحديث المشاهدات: $e");
    }
  }

  Future<void> placeBid(double bidAmount, String userId) async {
    if (!isAuction || bidAmount <= currentPrice) return;
    await FirebaseFirestore.instance.collection('products').doc(id).update({
      'currentPrice': bidAmount,
      'highestBidder': userId,
    });
  }
}
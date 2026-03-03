import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

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
  final Timestamp? endTime;

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
    this.endTime,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final dynamic rawData = doc.data();
    final Map<String, dynamic> data =
        rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};

    return ProductModel(
      id: doc.id,
      imageUrl: (data['imageUrl'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      size: (data['size'] ?? '').toString(),
      color: _parseColor(data['color']),
      description: (data['description'] ?? '').toString(),
      minPrice: _parseDouble(data['minPrice']),
      maxPrice: _parseDouble(data['maxPrice']),
      startPrice: _parseDouble(data['startPrice']),
      currentPrice: _parseDouble(data['currentPrice']),
      daysLeft: _parseInt(data['daysLeft']),
      views: _parseInt(data['views']),
      brand: (data['brand'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      state: (data['state'] ?? '').toString(),
      isSold: data['isSold'] == true,
      isFavourite: data['isFavourite'] == true,
      isPromoted: data['isPromoted'] == true,
      isAuction: data['isAuction'] == true,
      highestBidder: (data['highestBidder'] ?? '').toString(),
      condition: (data['condition'] ?? 'New').toString(),
      seller: (data['seller'] ?? '').toString(),
      sellerId: (data['sellerId'] ?? '').toString(),
      status: (data['status'] ?? 'On Going').toString(),
      endTime:
          data['endTime'] is Timestamp ? data['endTime'] as Timestamp : null,
    );
  }

  Future<void> updateViews() async {
    final DocumentReference productRef =
        FirebaseFirestore.instance.collection('products').doc(id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final DocumentSnapshot snapshot = await transaction.get(productRef);
      if (!snapshot.exists) {
        return;
      }

      final dynamic rawData = snapshot.data();
      final Map<String, dynamic> data =
          rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
      final int currentViews = _parseInt(data['views']);
      transaction.update(productRef, {'views': currentViews + 1});
    });
  }

  Future<void> placeBid(double bidAmount, String userId) async {
    if (!isAuction || bidAmount <= currentPrice) {
      return;
    }
    await FirebaseFirestore.instance.collection('products').doc(id).update({
      'currentPrice': bidAmount,
      'highestBidder': userId,
    });
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static Color _parseColor(dynamic value) {
    if (value is int) {
      return Color(value);
    }

    final String colorValue = value?.toString() ?? '';
    if (colorValue.startsWith('0x')) {
      final int? parsed = int.tryParse(colorValue.substring(2), radix: 16);
      if (parsed != null) {
        return Color(parsed);
      }
    }

    final int? parsedInt = int.tryParse(colorValue);
    if (parsedInt != null) {
      return Color(parsedInt);
    }

    return const Color(0xFF000000);
  }
}

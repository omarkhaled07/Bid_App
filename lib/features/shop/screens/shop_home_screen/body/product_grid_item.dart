import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductGridItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String maxPrice;
  final String startingPrice;
  final Timestamp? endTime; // ← أضف `endTime` لحساب الوقت المتبقي
  final bool isFavorite;
  final bool isOngoing;
  final String status;
  final VoidCallback? onFavoritePressed;

  const ProductGridItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.maxPrice,
    required this.startingPrice,
    required this.endTime, // ← استلم `endTime`
    required this.isFavorite,
    required this.isOngoing,
    required this.status,
    this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    String timeAgo = endTime != null
        ? _formatRemainingTime(endTime!)
        : status; // ← إذا لم يكن هناك وقت، استخدم الحالة

    return Container(
      width: 163,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xffE9EFEF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🕒 وقت الإعلان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    timeAgo, // ← عرض الوقت بنفس النمط المستخدم في `ProductCard`
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 8),

          // 🖼 صورة المنتج
          Center(
            child: SizedBox(
              height: 80,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, color: Colors.red);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return CircularProgressIndicator();
                },
              ),
            ),
          ),

          SizedBox(height: 8),

          // 📌 عنوان المنتج
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Color(0xff000000)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 8),

          // 💲 السعر
          Row(
            children: [
              Text(
                "\$$maxPrice",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 4),

          // ✅ حالة المنتج + السعر الابتدائي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Start | \$$startingPrice",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  color: isOngoing ? Colors.blue : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🕒 **دالة حساب الوقت المتبقي بنفس طريقة `ProductCard`**
  String _formatRemainingTime(Timestamp endTime) {
    final now = DateTime.now();
    final difference = endTime.toDate().difference(now);

    if (difference.inDays > 0) {
      return "${difference.inDays}d ${difference.inHours.remainder(24)}h left";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ${difference.inMinutes.remainder(60)}m left";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m left";
    } else {
      return "Less than a minute left";
    }
  }
}

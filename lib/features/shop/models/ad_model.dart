import 'package:cloud_firestore/cloud_firestore.dart';

class Ad {
  final String id; // ✅ إضافة id
  final String imageUrl;
  final String title;
  final String description;
  final int duration;
  final double cost;
  final String adUrl;
  final Timestamp timestamp; // ✅ إضافة timestamp


  Ad({
    required this.id, // ✅ تعديل
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.duration,
    required this.cost,
    required this.adUrl,
    required this.timestamp, // ✅ إضافة timestamp

  });

  // تحويل الإعلان إلى Map لإرساله لـ Firestore
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'duration': duration,
      'cost': cost,
      'adUrl': adUrl,
      'timestamp': timestamp, // ✅ تخزين timestamp

    };
  }

  // إنشاء كائن `Ad` من Firestore
  factory Ad.fromMap(String id, Map<String, dynamic> data) {
    return Ad(
      id: id,
      imageUrl: data['imageUrl'],
      title: data['title'],
      description: data['description'],
      duration: data['duration'],
      cost: data['cost'],
      adUrl: data['adUrl'],
      timestamp: data['timestamp'] ?? Timestamp.now(), // ✅ التعامل مع timestamp

    );
  }
}

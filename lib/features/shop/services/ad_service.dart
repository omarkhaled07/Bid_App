import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ad_model.dart';

class AdService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference adsCollection = _firestore.collection('ads');

  // إضافة إعلان جديد إلى Firestore
  static Future<String?> addAd(Ad ad) async {
    try {
      DocumentReference docRef = await adsCollection.add(ad.toMap());
      return docRef.id; // ✅ إرجاع id الجديد
    } catch (e) {
      throw Exception("Error adding ad: $e");
    }
  }

  static Future<void> deleteAd(String adId) async {
    try {
      await adsCollection.doc(adId).delete();
    } catch (e) {
      throw Exception("Error deleting ad: $e");
    }
  }



  // جلب الإعلانات من Firestore
  static Future<List<Ad>> fetchAds() async {
    try {
      QuerySnapshot snapshot = await adsCollection.orderBy('timestamp', descending: true).get();
      return snapshot.docs.map((doc) {
        return Ad.fromMap(doc.id, doc.data() as Map<String, dynamic>); // ✅ تمرير id
      }).toList();
    } catch (e) {
      throw Exception("Error fetching ads: $e");
    }
  }

}

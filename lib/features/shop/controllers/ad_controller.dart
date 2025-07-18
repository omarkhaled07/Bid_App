import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/ad_model.dart';
import '../services/ad_service.dart';

class AdController extends GetxController {
  var ads = <Ad>[].obs; // قائمة الإعلانات
  var isLoading = false.obs; // حالة التحميل

  @override
  void onInit() {
    fetchAds();
    super.onInit();
  }

  // جلب الإعلانات من Firestore
  Future<void> fetchAds() async {
    try {
      isLoading(true);
      final fetchedAds = await AdService.fetchAds();

      for (var ad in fetchedAds) {
        DateTime expirationDate = ad.timestamp.toDate().add(Duration(days: ad.duration));
        if (DateTime.now().isAfter(expirationDate)) {
          await AdService.deleteAd(ad.id); // ✅ استخدام id الصحيح
        }
      }

      ads.assignAll(fetchedAds.where((ad) => DateTime.now().isBefore(ad.timestamp.toDate().add(Duration(days: ad.duration)))));
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch ads: $e");
    } finally {
      isLoading(false);
    }
  }

  // إضافة إعلان جديد
  Future<void> addAd(Ad newAd) async {
    try {
      isLoading(true);
      String? adId = await AdService.addAd(newAd);
      if (adId != null) {
        final adWithId = Ad(
          id: adId, // ✅ إضافة id الجديد
          imageUrl: newAd.imageUrl,
          title: newAd.title,
          description: newAd.description,
          duration: newAd.duration,
          cost: newAd.cost,
          timestamp: Timestamp.now(),
          adUrl: newAd.adUrl// ✅ التأكد من أن timestamp غير null
        );
        ads.add(adWithId);
        update(); // تحديث الواجهة
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to add ad: $e");
    } finally {
      isLoading(false);
    }
  }

}

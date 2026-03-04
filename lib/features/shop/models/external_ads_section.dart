import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/ad_controller.dart';
import '../screens/AdScreen/add_ad_screen.dart';

class ExternalAdsSection extends StatefulWidget {
  const ExternalAdsSection({super.key});

  @override
  _ExternalAdsSectionState createState() => _ExternalAdsSectionState();
}

class _ExternalAdsSectionState extends State<ExternalAdsSection> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentAdIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AdController adController = Get.find<AdController>();

    return Obx(() {
      if (adController.isLoading.value) {
        return Center(
            child: CircularProgressIndicator(color: Color(0xffFFE70C)));
      }

      return Column(
        children: [
          if (adController.ads.isNotEmpty) // 👈 لو فيه إعلانات، نعرضها
            Column(
              children: [
                SizedBox(
                  height: 250, // 👈 ارتفاع القائمة الأفقية
                  child: PageView.builder(
                    controller: _pageController,
                    padEnds: false,
                    onPageChanged: (index) {
                      setState(() {
                        _currentAdIndex = index; // 👈 تحديث المؤشر
                      });
                    },
                    itemCount: adController.ads.length,
                    itemBuilder: (context, index) {
                      final ad = adController.ads[index];
                      return GestureDetector(
                        onTap: () {
                          if (ad.adUrl.isNotEmpty) {
                            launchUrl(
                                Uri.parse(ad.adUrl)); // 👈 فتح رابط الإعلان
                          }
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // صورة الإعلان
                                CachedNetworkImage(
                                  imageUrl: ad.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                        color: Color(0xffFFE70C)),
                                  ),
                                  errorWidget: (context, url, error) {
                                    print(
                                        "Error loading image: $url"); // 👈 طباعة الخطأ
                                    return Icon(Icons.error,
                                        color: Colors.red); // 👈 أيقونة خطأ
                                  },
                                ),
                                // طبقة تظليل
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                // تفاصيل الإعلان
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ad.title,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        ad.description,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                // مؤشر الصفحات
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    adController.ads.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentAdIndex == index
                            ? Color(0xffFFE70C)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 20), // 👈 مسافة بين الإعلانات والبانر
          _buildNoAdsBanner(), // 👈 نعرض البانر دائمًا
        ],
      );
    });
  }

  Widget _buildNoAdsBanner() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xff19172D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            "Add your ad now!",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Add your ad now and reach thousands of users!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 👈 توجه اليوزر لصفحة إضافة إعلان جديد
              Get.to(() => AddAdScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffFFE70C),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              "Add New Ad",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




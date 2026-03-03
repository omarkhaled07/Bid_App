import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../ProductDescriptionScreen/product_description_screen.dart';
import '../shop_home_screen/body/product_grid_item.dart';
import '../shop_home_screen/shop_home_screen.dart';
import '../cartScreen/cart_screen.dart';
import '../liveScreen/live_screen.dart';
import '../shop_home_screen/nav_bar/custom_bottom_nav.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductController productController = Get.put(ProductController());
  int _currentIndex = 1; // المفضلة

  User? get currentUser => _auth.currentUser;

  void _onNavTap(int index) {
    // عكس الفهارس لتتناسب مع الترتيب المعكوس للأيقونات
    int reversedIndex = 3 - index; // 3 هو عدد العناصر - 1
    setState(() => _currentIndex = reversedIndex);
    switch (reversedIndex) {
      case 0:
        Get.off(() => ShopHomeScreen());
        break;
      case 1: // المفضلة
        Get.off(() => FavoritesPage());
        break;
      case 2: // السلة
        Get.off(() => ShoppingCartPage());
        break;
      case 3: // البث المباشر
        Get.off(() => LivePage());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المفضلة", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff080618),
      ),
      body: currentUser == null
          ? const Center(
              child: Text(
                "يجب تسجيل الدخول لعرض المفضلة",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : StreamBuilder(
              stream: _firestore
                  .collection('favorites')
                  .where('userId', isEqualTo: currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "لا توجد منتجات مضافة إلى المفضلة بعد",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }
                var favoriteItems = snapshot.data!.docs;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: favoriteItems.length,
                    itemBuilder: (context, index) {
                      var favoriteItem = favoriteItems[index];
                      var productId = favoriteItem['productId'];
                      return FutureBuilder(
                        future: _firestore
                            .collection('products')
                            .doc(productId)
                            .get(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> productSnapshot) {
                          if (productSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!productSnapshot.hasData ||
                              !productSnapshot.data!.exists) {
                            return Card(
                              color: const Color(0xff1a1a2e),
                              child: Center(
                                child: Text("المنتج غير متوفر",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            );
                          }
                          var productData = productSnapshot.data!.data()
                              as Map<String, dynamic>;
                          return _buildFavoriteProductItem(
                              productData, productId);
                        },
                      );
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildFavoriteProductItem(
      Map<String, dynamic> productData, String productId) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDescriptionScreen(
              productId: productId,
              onFavoriteToggle: (isFavorite) => setState(() {}),
            ));
      },
      child: Stack(
        children: [
          ProductGridItem(
            imageUrl: productData['imageUrl'] ?? '',
            title: productData['title'] ?? '',
            maxPrice: productData['maxPrice']?.toString() ?? '0',
            startingPrice: productData['minPrice']?.toString() ?? '0',
            endTime: productData['endTime'],
            isFavorite: true,
            isOngoing: productData['isSold'] ?? false,
            status: productData['status'] ?? 'On Going',
          ),
        ],
      ),
    );
  }
}

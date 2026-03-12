import 'package:bid/features/shop/screens/shop_home_screen/body/product_card.dart';
import 'package:bid/features/shop/screens/shop_home_screen/body/product_grid_item.dart';
import 'package:bid/features/shop/screens/shop_home_screen/app_bar/shop_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../authentication/models/auth_view_model.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/ad_controller.dart';
import '../../models/ad_model.dart';
import '../AdScreen/add_ad_screen.dart';
import '../ProductDescriptionScreen/product_description_screen.dart';
import '../allProductScreen/non_promoted_products_screen.dart';
import '../allProductScreen/promoted_products_screen.dart';
import '../cartScreen/cart_screen.dart';
import '../favoriteScreen/favorite_screen.dart';
import '../liveScreen/live_screen.dart';
import 'floating_action_button/floating_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'nav_bar/custom_bottom_nav.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  _ShopHomeScreenState createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  final ProductController productController = Get.put(ProductController());
  final AdController adController = Get.put(AdController());
  final AuthViewModel authViewModel = Get.find<AuthViewModel>();
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _selectedIndex = 0;
  int _currentIndex = 0; // تم تعديل القيمة إلى 0 لأنها الصفحة الرئيسية (مزاد)

  @override
  void initState() {
    super.initState();
    adController.fetchAds();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
      backgroundColor: Color(0xff080618),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ShopAppBarWidget(),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await productController.fetchProducts();
            await adController.fetchAds();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  "Promoted Products",
                  "Explore the best deals on promoted products!",
                  isPromotedSection: true,
                ),
                _buildPromotedProductsCarousel(),
                _buildCarouselIndicator(),
                const SizedBox(height: 50),
                _buildSectionHeader(
                  "External Ads",
                  "Check out these amazing external offers!",
                  showSeeAll: false,
                ),
                _buildExternalAdsSection(),
                const SizedBox(height: 50),
                _buildSectionHeader(
                  "Ongoing on Mazad",
                  "Don't miss out on these ongoing auctions!",
                ),
                _buildProductGrid(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingBTN(),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  // بقية الدوال مثل _buildSectionHeader و _buildPromotedProductsCarousel تبقى كما هي
  // سنعدل فقط _buildProductGrid

  Widget _buildProductGrid() {
    return Obx(() {
      if (productController.isLoading.value) {
        return Center(
            child: CircularProgressIndicator(color: Color(0xffFFE70C)));
      }
      if (productController.products.isEmpty) {
        return Center(
            child: Text("No products available",
                style: TextStyle(color: Colors.white)));
      }
      final displayedProducts = productController.products.take(6).toList();
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: displayedProducts.length,
        itemBuilder: (context, index) {
          final product = displayedProducts[index];
          return GestureDetector(
            onTap: () {
              Get.to(() => ProductDescriptionScreen(
                    productId: product.id,
                    onFavoriteToggle: (isFavorite) {
                      product.isFavourite = isFavorite;
                      productController.products.refresh();
                    },
                  ));
            },
            child: Stack(
              children: [
                ProductGridItem(
                  imageUrl: product.imageUrl,
                  title: product.title,
                  maxPrice: product.maxPrice.toString(),
                  startingPrice: product.startPrice.toString(),
                  endTime: product.endTime,
                  isFavorite: product.isFavourite,
                  isOngoing: product.isSold,
                  status: product.status,
                ),
                Positioned(
                  top: 10,
                  right: Get.locale?.languageCode == 'ar' ? null : 20,
                  left: Get.locale?.languageCode == 'ar' ? 20 : null,
                  child: GestureDetector(
                    onTap: () {
                      final bool hasUser =
                          FirebaseAuth.instance.currentUser != null;
                      if (!hasUser || authViewModel.isGuestMode.value) {
                        Get.snackbar(
                          "Sign in required",
                          "Guest users can browse only. Please sign in to manage favorites.",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      toggleFavorite(product.id, product.title);
                      productController.toggleFavorite(product.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: product.isFavourite
                            ? Colors.orangeAccent
                            : Colors.white,
                      ),
                      child: Icon(
                        Icons.favorite_border_outlined,
                        color:
                            product.isFavourite ? Colors.white : Colors.black,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // بقية الدوال مثل toggleFavorite تبقى كما هي
  Future<void> toggleFavorite(String productId, String productName) async {
    final bool hasUser = FirebaseAuth.instance.currentUser != null;
    if (!hasUser || authViewModel.isGuestMode.value) {
      Get.snackbar(
        "Sign in required",
        "Guest users can browse only. Please sign in to manage favorites.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      final QuerySnapshot snapshot = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: currentUser.uid)
          .where('productId', isEqualTo: productId)
          .get();

      if (snapshot.docs.isEmpty) {
        await firestore.collection('favorites').add({
          'userId': currentUser.uid,
          'productId': productId,
          'productName': productName,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    }
  }

  Widget _buildSectionHeader(String title, String subtitle,
      {bool showSeeAll = true, bool isPromotedSection = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                color: Color(0xffDADADA),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showSeeAll)
              GestureDetector(
                onTap: () {
                  if (isPromotedSection) {
                    final promotedProducts = productController.products
                        .where((product) => product.isPromoted)
                        .toList();
                    Get.to(() => PromotedProductsScreen(
                        promotedProducts: promotedProducts));
                  } else {
                    final nonPromotedProducts = productController.products
                        .where((product) => !product.isPromoted)
                        .toList();
                    Get.to(() => NonPromotedProductsScreen(
                        nonPromotedProducts: nonPromotedProducts));
                  }
                },
                child: Text(
                  "See All",
                  style: TextStyle(fontSize: 18, color: Color(0xffFFE70C)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
              fontSize: 16, color: Color(0xffDADADA).withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 45),
      ],
    );
  }

  Widget _buildPromotedProductsCarousel() {
    return SizedBox(
      height: 350,
      child: Obx(() {
        if (productController.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(color: Color(0xffFFE70C)));
        }
        final promotedProducts = productController.products
            .where((product) => product.isPromoted)
            .toList();
        if (promotedProducts.isEmpty) {
          return Center(
              child: Text("No promoted products available",
                  style: TextStyle(color: Colors.white)));
        }
        return PageView.builder(
          controller: _pageController,
          clipBehavior: Clip.none,
          itemCount: promotedProducts.length,
          onPageChanged: (index) => setState(() => _selectedIndex = index),
          itemBuilder: (context, index) {
            final product = promotedProducts[index];
            bool isActive = index == _selectedIndex;
            return AnimatedPadding(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                  horizontal: 8, vertical: isActive ? 0 : 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProductDescriptionScreen(productId: product.id)),
                  );
                },
                child: Transform.scale(
                  scale: isActive ? 1.05 : 0.95,
                  child: ProductCard(product: product, isSelected: isActive),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCarouselIndicator() {
    return Obx(() {
      final promotedProducts = productController.products
          .where((product) => product.isPromoted)
          .toList();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          promotedProducts.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _selectedIndex == index ? Color(0xffFFE70C) : Colors.grey,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExternalAdsSection() {
    final PageController pageController = PageController(viewportFraction: 0.9);
    int currentAdIndex = 0;

    return Obx(() {
      if (adController.isLoading.value) {
        return Center(
            child: CircularProgressIndicator(color: Color(0xffFFE70C)));
      }
      return Column(
        children: [
          if (adController.ads.isNotEmpty)
            Column(
              children: [
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    controller: pageController,
                    padEnds: false,
                    onPageChanged: (index) =>
                        setState(() => currentAdIndex = index),
                    itemCount: adController.ads.length,
                    itemBuilder: (context, index) {
                      final ad = adController.ads[index];
                      return GestureDetector(
                        onTap: () {
                          if (ad.adUrl.isNotEmpty)
                            launchUrl(Uri.parse(ad.adUrl));
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
                                  offset: Offset(0, 5)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: ad.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                          color: Color(0xffFFE70C))),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error, color: Colors.red),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.7),
                                        Colors.transparent
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(ad.title,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(height: 8),
                                      Text(ad.description,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white
                                                  .withValues(alpha: 0.9))),
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
                        color: currentAdIndex == index
                            ? Color(0xffFFE70C)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 20),
          _buildNoAdsBanner(),
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
          Text("Add your ad now!",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Add your ad now and reach thousands of users!",
              style:
                  TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
              textAlign: TextAlign.center),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final bool hasUser = FirebaseAuth.instance.currentUser != null;
              if (!hasUser || authViewModel.isGuestMode.value) {
                Get.snackbar(
                  "Sign in required",
                  "Guest users can browse only. Please sign in to add ads.",
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              Get.to(() => AddAdScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffFFE70C),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("Add New Ad",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class ExternalAdItem extends StatelessWidget {
  final Ad ad;

  const ExternalAdItem({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (ad.adUrl.isNotEmpty) launchUrl(Uri.parse(ad.adUrl));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(ad.imageUrl,
                  height: 120, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad.title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 8),
                  Text(ad.description,
                      style: TextStyle(
                          fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


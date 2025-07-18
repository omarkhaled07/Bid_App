import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  var products = <ProductModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('products').get();
      products.assignAll(querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList());
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch products",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'title': product.title,
        'size': product.size,
        'color': product.color.value.toString(),
        'description': product.description,
        'imageUrl': product.imageUrl,
        'minPrice': product.minPrice,
        'currentPrice': product.currentPrice,
        'daysLeft': product.daysLeft,
        'views': product.views,
        'brand': product.brand,
        'category': product.category,
        'state': product.state,
        'isSold': product.isSold,
        'isFavourite': product.isFavourite,
        'isPromoted': product.isPromoted,
        'isAuction': product.isAuction,
        'highestBidder': product.highestBidder,
        'condition': product.condition,
        'seller': product.seller,
        'sellerId': product.sellerId,
        'status': product.status,
        'createdAt': FieldValue.serverTimestamp(),
      });
      fetchProducts();
    } catch (e) {
      Get.snackbar("Error", "Failed to add product",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void toggleFavorite(String productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      products[index] = ProductModel(
        id: products[index].id,
        imageUrl: products[index].imageUrl,
        title: products[index].title,
        size: products[index].size,
        color: products[index].color,
        description: products[index].description,
        minPrice: products[index].minPrice,
        maxPrice: products[index].maxPrice,
        startPrice: products[index].startPrice,
        currentPrice: products[index].currentPrice,
        daysLeft: products[index].daysLeft,
        views: products[index].views,
        brand: products[index].brand,
        category: products[index].category,
        state: products[index].state,
        isSold: products[index].isSold,
        isFavourite: !products[index].isFavourite, // تحديث القيمة هنا
        isPromoted: products[index].isPromoted,
        isAuction: products[index].isAuction,
        highestBidder: products[index].highestBidder,
        condition: products[index].condition,
        seller: products[index].seller,
        sellerId: products[index].sellerId,
        status: products[index].status,
      );
      products.refresh();

      // تحديث قاعدة البيانات
      FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'isFavourite': products[index].isFavourite});
    }
  }

}

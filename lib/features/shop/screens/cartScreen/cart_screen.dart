import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../PaymentScreen/payment_screen.dart';
import '../favoriteScreen/favorite_screen.dart';
import '../liveScreen/live_screen.dart';
import '../shop_home_screen/nav_bar/custom_bottom_nav.dart';
import '../shop_home_screen/shop_home_screen.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({Key? key}) : super(key: key);

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  int _currentIndex = 2;

  String name = "";
  String email = "";
  String phone = "";
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'] ?? "No Name";
          email = userDoc['email'] ?? "No Email";
          phone = userDoc['phone'] ?? "No Phone";
          isLoadingUser = false;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        isLoadingUser = false;
      });
    }
  }

  Future<void> _removeItem(String docId) async {
    await FirebaseFirestore.instance
        .collection('carts')
        .doc(userId)
        .collection('items')
        .doc(docId)
        .delete();
  }

  Future<void> _updateQuantity(String docId, int newQuantity) async {
    if (newQuantity > 0) {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(docId)
          .update({'quantity': newQuantity});
    } else {
      _removeItem(docId);
    }
  }

  Future<String?> _fetchPaymobApiKey() async {
    try {
      DocumentSnapshot paymentSettings = await FirebaseFirestore.instance
          .collection('payment_settings')
          .doc('keys')
          .get();
      if (paymentSettings.exists) {
        return paymentSettings['PaymobApiKey'] as String?;
      }
    } catch (e) {
      print("Error fetching Paymob API key: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shopping Cart")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('carts')
            .doc(userId)
            .collection('items')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || isLoadingUser) {
            return const Center(child: CircularProgressIndicator());
          }

          var cartItems = snapshot.data!.docs;
          double totalPrice = cartItems.fold(
              0,
              (sum, item) =>
                  sum + ((item['price'] ?? 0) * (item['quantity'] ?? 1)));

          List<String> productIds = cartItems
              .map((item) => item['productId'] as String)
              .where((id) => id.isNotEmpty)
              .toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index].data() as Map<String, dynamic>;
                    String docId = cartItems[index].id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['imageUrl'] ?? "",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] ?? "No Title",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "\$${item['price']?.toStringAsFixed(2) ?? "0.00"}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _updateQuantity(
                                            docId, (item['quantity'] ?? 1) - 1),
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                      ),
                                      Text(
                                        "${item['quantity'] ?? 1}",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      IconButton(
                                        onPressed: () => _updateQuantity(
                                            docId, (item['quantity'] ?? 1) + 1),
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(docId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "\$${totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.green,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (isLoadingUser) return;
                        String? paymentKey = await _fetchPaymobApiKey();
                        if (paymentKey == null) {
                          Get.snackbar(
                            "Error",
                            "Failed to fetch payment key",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        Get.to(() => PaymentScreen(
                              amount: totalPrice,
                              paymentKey: paymentKey,
                              productIds: productIds,
                            ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 60),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isLoadingUser
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Proceed to Checkout",
                              style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          int reversedIndex = 3 - index;
          setState(() => _currentIndex = reversedIndex);
          switch (reversedIndex) {
            case 0:
              Get.off(() => ShopHomeScreen());
              break;
            case 1:
              Get.off(() => FavoritesPage());
              break;
            case 2:
              Get.off(() => ShoppingCartPage());
              break;
            case 3:
              Get.off(() => LivePage());
              break;
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/product_model.dart';
import '../../ProductDescriptionScreen/product_description_screen.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isSelected;

  const ProductCard(
      {super.key, required this.product, required this.isSelected});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    String daysText = widget.product.status ??
        (widget.product.endTime != null &&
                widget.product.endTime!.toDate().isAfter(DateTime.now())
            ? _formatRemainingTime(widget.product.endTime!)
            : (widget.product.isSold ? "Sold" : "Finished"));

    return GestureDetector(
      onTap: () async {
        await _incrementViews(
            widget.product.id, context); // تحديث عدد المشاهدات
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDescriptionScreen(productId: widget.product.id),
          ),
        );
      },
      child: Transform.scale(
        scale: widget.isSelected ? 1.1 : 0.9,
        child: Container(
          width: 319,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(width: 2, color: const Color(0xffCDF1FE)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff777680),
                Color(0xff406165),
              ],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 126,
                    width: 120,
                    child: Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb,
                            color: Colors.yellow, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          daysText,
                          style: const TextStyle(color: Colors.yellow),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye_outlined,
                            color: Color(0xffFEFAE5), size: 16),
                        const SizedBox(width: 4),
                        Text("${widget.product.views}",
                            style: const TextStyle(color: Color(0xffFEFAE5))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.product.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Lato",
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  "${widget.product.brand} | ${widget.product.category} | ${widget.product.state}",
                  style:
                      const TextStyle(color: Color(0xffD4D4D4), fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${widget.product.maxPrice}",
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    if (widget.product.isSold)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text("Sold",
                                style: TextStyle(
                                    color: Colors.green, fontSize: 14)),
                          ],
                        ),
                      ),
                    if (widget.product.endTime != null)
                      _buildEndTimeDisplay(widget.product.endTime!),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildEndTimeDisplay(Timestamp endTime) {
    final remainingTime = _formatRemainingTime(endTime);
    return Text(
      remainingTime,
      style: const TextStyle(
          color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
    );
  }

  Future<void> _incrementViews(String productId, BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("User not logged in");
        return;
      }
      final userId = user.uid;

      // جلب بيانات المنتج أولاً للتحقق مما إذا كان المستخدم قد شاهد المنتج من قبل
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productDoc.exists) {
        final viewedBy = productDoc.data()?['viewedBy'] as List<dynamic>? ?? [];

        // إذا كان المستخدم لم يشاهد المنتج من قبل
        if (!viewedBy.contains(userId)) {
          debugPrint(
              "Updating views for Product ID: $productId, User ID: $userId");

          await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .update({
            'views': FieldValue.increment(1),
            'viewedBy': FieldValue.arrayUnion([userId]),
            'lastViewed': FieldValue.serverTimestamp(),
          });

          debugPrint("Views updated successfully for product: $productId");
        } else {
          debugPrint(
              "User already viewed this product, not incrementing views");
        }
      }
    } catch (e) {
      debugPrint('Error updating views: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update views, please try again')),
        );
      }
    }
  }
}

class ProductList extends StatefulWidget {
  final List<ProductModel> products;

  const ProductList({super.key, required this.products});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final PageController _pageController = PageController(viewportFraction: 0.75);
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.products.length,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ProductCard(
              product: widget.products[index],
              isSelected: (_selectedIndex == index),
            ),
          );
        },
      ),
    );
  }
}

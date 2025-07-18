import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../ProductDescriptionScreen/product_description_screen.dart';
import 'filter_bottom_sheet.dart';

class PromotedProductsScreen extends StatefulWidget {
  final List<ProductModel> promotedProducts;

  const PromotedProductsScreen({required this.promotedProducts, super.key});

  @override
  _PromotedProductsScreenState createState() => _PromotedProductsScreenState();
}

class _PromotedProductsScreenState extends State<PromotedProductsScreen> {
  String? selectedCategory;
  String? selectedStatus;

  List<ProductModel> get filteredProducts {
    return widget.promotedProducts.where((product) {
      final categoryMatch = selectedCategory == null || product.category == selectedCategory;
      final statusMatch = selectedStatus == null || product.status == selectedStatus;
      return categoryMatch && statusMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff080618),
      appBar: AppBar(
        title: Text("Promoted Products"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return FilterBottomSheet(
                    onCategorySelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    onStatusSelected: (status) {
                      setState(() {
                        selectedStatus = status;
                      });
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDescriptionScreen(productId: product.id),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Color(0xff19172D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      product.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Price: \$${product.maxPrice}",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xffFFE70C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

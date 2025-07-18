import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../shop_home_screen/body/product_grid_item.dart';
import 'filter_bottom_sheet.dart';

class NonPromotedProductsScreen extends StatefulWidget {
  final List<ProductModel> nonPromotedProducts;

  const NonPromotedProductsScreen({required this.nonPromotedProducts, super.key});

  @override
  _NonPromotedProductsScreenState createState() =>
      _NonPromotedProductsScreenState();
}

class _NonPromotedProductsScreenState extends State<NonPromotedProductsScreen> {
  String? selectedCategory;
  String? selectedStatus;

  List<ProductModel> get filteredProducts {
    return widget.nonPromotedProducts.where((product) {
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
        title: Text("All Products"),
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
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return ProductGridItem(
            imageUrl: product.imageUrl,
            title: product.title,
            maxPrice: product.maxPrice.toString(),
            startingPrice: product.minPrice.toString(),
            endTime: product.endTime,
            isFavorite: index % 2 == 0,
            isOngoing: index % 2 != 0,
            status: product.status,
          );
        },
      ),
    );
  }
}

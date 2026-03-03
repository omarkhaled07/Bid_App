import 'package:bid/features/shop/models/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/home_services.dart';
import 'category_model.dart';

class HomeViewModel extends GetxController {
  ValueNotifier<bool> get loading => _loading;
  final ValueNotifier<bool> _loading = ValueNotifier(false);

  List<CategoryModel> get categoryModel => _categoryModel;
  final List<CategoryModel> _categoryModel = [];

  List<ProductModel> get productModel => _productModel;
  final List<ProductModel> _productModel = [];

  HomeViewModel() {
    getCategory();
    getBestSellingProducts();
  }

  Future<void> getCategory() async {
    _loading.value = true;
    update();

    try {
      List<dynamic> value = await HomeService().getCategory();
      _categoryModel.assignAll(
          value.map((e) => CategoryModel.fromJson(e.data())).toList());
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      _loading.value = false;
      update();
    }
  }

  Future<void> getBestSellingProducts() async {
    _loading.value = true;
    update();

    try {
      List<dynamic> value = await HomeService().getBestSelling();
      _productModel
          .assignAll(value.map((e) => ProductModel.fromFirestore(e)).toList());
    } catch (e) {
      print("Error fetching best-selling products: $e");
    } finally {
      _loading.value = false;
      update();
    }
  }
}

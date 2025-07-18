import 'package:flutter/material.dart';
import '../models/product_model.dart';

class DetailsView extends StatelessWidget {
  final ProductModel model;

  const DetailsView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 270,
            child: Image.network(
              model.imageUrl, // ✅ تصحيح الوصول إلى الصورة
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.title, // ✅ تصحيح الوصول إلى `title`
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          width: MediaQuery.of(context).size.width * .4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('Size', style: TextStyle(fontSize: 16)),
                              Text(model.size, style: TextStyle(fontSize: 16)), // ✅ تصحيح `size`
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          width: MediaQuery.of(context).size.width * .44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('Color', style: TextStyle(fontSize: 16)),
                              Container(
                                width: 30,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(20),
                                  color: model.color, // ✅ اللون يجب أن يكون `Color`
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      model.description, // ✅ تأكد أن `description` موجودة
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PRICE",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Text(
                      '\$${model.minPrice.toStringAsFixed(2)} - \$${model.currentPrice.toStringAsFixed(2)}', // ✅ تحديث السعر
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
                SizedBox(
                  width: 180,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // تنفيذ الإجراء عند الضغط على زر "Add"
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text("Add", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

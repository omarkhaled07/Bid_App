import 'package:flutter/material.dart';

class FilterBottomSheet extends StatelessWidget {
  final Function(String?) onCategorySelected;
  final Function(String?) onStatusSelected;

  const FilterBottomSheet({
    required this.onCategorySelected,
    required this.onStatusSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Filter by Category",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            hint: Text("Select Category"),
            onChanged: onCategorySelected,
            items: [
              'Bags',
              'Accessories',
              'Shoes',
              'Jewelry',
              'Watches',
              'Fashion'
            ]
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
          ),
          SizedBox(height: 20),
          Text(
            "Filter by Status",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            hint: Text("Select Status"),
            onChanged: onStatusSelected,
            items: [
              "On Going",
              "Sold",
            ]
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(12)));

    final dashedPath = dashPath(
      path,
      dashArray: CircularIntervalList([6, 4]), // تحديد الطول والمسافة بين الشرطات
    );

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

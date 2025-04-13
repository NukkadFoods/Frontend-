import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class DottedLinePainter extends CustomPainter {
  final double dashHeight;
  final double dashSpace;
  final Color color;

  DottedLinePainter({
    this.dashHeight = 5.0,
    this.dashSpace = 3.0,
    this.color = colorBrightGreen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DottedLinePainter oldDelegate) => false;
}

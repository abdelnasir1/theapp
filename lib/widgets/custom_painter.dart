import 'package:flutter/cupertino.dart';

class PaperBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base color
    final base = Paint()..color = const Color(0xFFFCFCD8);
    canvas.drawRect(Offset.zero & size, base);

    // Subtle horizontal lines (matches the original pattern)
    final dark = Paint()
      ..color = const Color(0xFFF4F4BB) // darker band
      ..style = PaintingStyle.fill;

    const period = 4.0; // every 4 pixels
    for (double y = 0; y < size.height; y += period) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, 1),
        dark,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
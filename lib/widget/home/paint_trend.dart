import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snapmug/core/class/colors.dart';

class RPSCustomPainter extends CustomPainter {
  final double borderRadius;

  RPSCustomPainter({this.borderRadius = 15.0});

  @override
  void paint(Canvas canvas, Size size) {
    // حساب النقاط الرئيسية بدقة
    final double left = 0;
    final double top = size.height * 0.1020000;
    final double bottom = size.height * 0.9040000;
    final double right = size.width;
    final double bottomEnd = size.height * 0.9980000;
    final double topEnd = 0;

    // حساب نصف القطر مع مراعاة حدود الشكل
    final double radius = min(borderRadius, min(size.width, size.height) * 0.3);

    // طبقة التعبئة
    Paint paintFill = Paint()
      ..color = const Color.fromARGB(0, 255, 255, 255)
      ..style = PaintingStyle.fill;

    Path path = Path();

    // الزاوية اليسرى العليا
    path.moveTo(left + radius, top);
    path.quadraticBezierTo(left, top, left, top + radius);

    // الجانب الأيسر
    path.lineTo(left, bottom - radius);

    // الزاوية اليسرى السفلى
    path.quadraticBezierTo(left, bottom, left + radius, bottom);

    // الجانب السفلي
    path.lineTo(right - radius, bottomEnd);

    // الزاوية اليمنى السفلى
    path.quadraticBezierTo(right, bottomEnd, right, bottomEnd - radius);

    // الجانب الأيمن
    path.lineTo(right, topEnd + radius);

    // الزاوية اليمنى العليا
    path.quadraticBezierTo(right, topEnd, right - radius, topEnd);

    // الجانب العلوي
    path.lineTo(left + radius, top);

    canvas.drawPath(path, paintFill);

    // طبقة الحدود
    Paint paintStroke = Paint()
      ..color = AppColors.yellowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

///////////////////////// image
class CustomShapeClipper extends CustomClipper<Path> {
  final double borderRadius;

  CustomShapeClipper({required this.borderRadius});

  @override
  Path getClip(Size size) {
    final path = Path();

    // نفس النقاط الرئيسية المستخدمة في RPSCustomPainter
    final double left = 0;
    final double top = size.height * 0.1020000;
    final double bottom = size.height * 0.9040000;
    final double right = size.width;
    final double bottomEnd = size.height * 0.9980000;
    final double topEnd = 0;

    final double radius = min(borderRadius, min(size.width, size.height) * 0.3);

    // الزاوية اليسرى العليا (تطابق RPSCustomPainter)
    path.moveTo(left + radius, top);
    path.quadraticBezierTo(left, top, left, top + radius);

    // الجانب الأيسر
    path.lineTo(left, bottom - radius);

    // الزاوية اليسرى السفلى
    path.quadraticBezierTo(left, bottom, left + radius, bottom);

    // الجانب السفلي
    path.lineTo(right - radius, bottomEnd);

    // الزاوية اليمنى السفلى
    path.quadraticBezierTo(right, bottomEnd, right, bottomEnd - radius);

    // الجانب الأيمن
    path.lineTo(right, topEnd + radius);

    // الزاوية اليمنى العليا
    path.quadraticBezierTo(right, topEnd, right - radius, topEnd);

    // الجانب العلوي
    path.lineTo(left + radius, top);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

import 'package:flutter/material.dart';

class ColorConstant {
  ColorConstant._();

  static const Color primary = Color(0xFFE5484D);
  static const Color green = Color(0xFF12A594);
  static const Color brand = Color(0xFF4F46E5);
  static const Color brandDark = Color(0xFF3730A3);
  static const Color purple = Color(0xFF7C3AED);
  static const Color amber = Color(0xFFF59E0B);

  static const Color background = Color(0xFFF5F6FB);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF1E2235);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7F0);
  static const Color whatsapp = Color(0xFF25D366);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [brand, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
import 'package:flutter/material.dart';
import 'app_colors.dart' show ColorConstant;

class StyleConstant {
  StyleConstant._();

  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: ColorConstant.textDark,
  );

  static const TextStyle title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ColorConstant.textDark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: ColorConstant.textDark,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.5,
    color: ColorConstant.textGrey,
  );

  static const TextStyle balanceBig = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
  );
}
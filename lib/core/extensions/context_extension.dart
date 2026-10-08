import 'package:flutter/material.dart';
import '../constants/app_colors.dart';


extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? ColorConstant.primary : ColorConstant.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void hideDialog() => Navigator.of(this, rootNavigator: true).pop();

  void dismissKeyboard() => FocusScope.of(this).unfocus();

  Future<T?> navigateTo<T>(Widget screen) {
    return Navigator.push<T>(this, MaterialPageRoute(builder: (_) => screen));
  }

  void goBack() => Navigator.pop(this);

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isSmallScreen => screenWidth < 600;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 900;
  bool get isLargeScreen => screenWidth >= 900;

  double getWidth([double percent = 1]) => screenWidth * percent;
  double getHeight([double percent = 1]) => screenHeight * percent;
}
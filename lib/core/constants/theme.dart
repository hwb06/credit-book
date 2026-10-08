import 'package:flutter/material.dart';
import 'package:udhaar_app/core/constants/app_colors.dart';
import 'package:udhaar_app/core/constants/app_dimensions.dart';


class AppTheme {
  AppTheme._();

  static OutlineInputBorder _border(Color c, [double w = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(DimensionConstant.radius),
        borderSide: BorderSide(color: c, width: w),
      );

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: ColorConstant.brand,
      brightness: Brightness.light,
    ).copyWith(
      primary: ColorConstant.brand,
      error: ColorConstant.primary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ColorConstant.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorConstant.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: ColorConstant.textDark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ColorConstant.textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstant.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, DimensionConstant.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DimensionConstant.radius),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorConstant.brand,
          minimumSize: const Size(0, DimensionConstant.buttonHeight),
          side: const BorderSide(color: ColorConstant.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DimensionConstant.radius),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ColorConstant.brand,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DimensionConstant.radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIconColor: ColorConstant.textGrey,
        border: _border(ColorConstant.border),
        enabledBorder: _border(ColorConstant.border),
        focusedBorder: _border(ColorConstant.brand, 1.6),
        errorBorder: _border(ColorConstant.primary),
        focusedErrorBorder: _border(ColorConstant.primary, 1.6),
      ),
    );
  }
}
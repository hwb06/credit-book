import 'package:flutter/material.dart';
import 'package:udhaar_app/core/constants/app_colors.dart';
import 'package:udhaar_app/core/constants/app_dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DimensionConstant.padding),
    this.margin,
    this.onTap,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(DimensionConstant.radiusLarge - 4);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? ColorConstant.card,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? ColorConstant.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1E2235),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
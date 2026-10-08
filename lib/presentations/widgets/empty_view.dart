import 'package:flutter/material.dart';
import 'package:udhaar_app/core/constants/app_colors.dart';
import 'package:udhaar_app/core/constants/app_styles.dart';

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const EmptyView({
    super.key,
    required this.icon,
    required this.text,
    this.color = ColorConstant.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: StyleConstant.caption.copyWith(fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
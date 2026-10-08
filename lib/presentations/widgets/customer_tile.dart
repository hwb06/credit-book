import 'package:flutter/material.dart';
import 'package:udhaar_app/core/constants/app_colors.dart';
import 'package:udhaar_app/core/constants/app_styles.dart';
import 'package:udhaar_app/data/models/customer_model.dart';
import 'package:udhaar_app/presentations/widgets/app_card.dart';

class InitialAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;

  const InitialAvatar({
    super.key,
    required this.name,
    this.size = 46,
    this.color,
  });

  static const _palette = [
    ColorConstant.brand,
    ColorConstant.green,
    ColorConstant.purple,
    ColorConstant.amber,
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
  ];

  @override
  Widget build(BuildContext context) {
    final c = color ??
        _palette[name.isEmpty ? 0 : name.codeUnitAt(0) % _palette.length];
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

class CustomerTile extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;
  final Widget? trailing; // balance chip

  const CustomerTile({
    super.key,
    required this.customer,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          InitialAvatar(name: customer.name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleConstant.title),
                const SizedBox(height: 2),
                Text(customer.phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleConstant.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              const Icon(Icons.chevron_right, color: ColorConstant.textGrey),
        ],
      ),
    );
  }
}
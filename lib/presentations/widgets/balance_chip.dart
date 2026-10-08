import 'package:flutter/material.dart';
import 'package:udhaar_app/core/constants/app_colors.dart';
import 'package:udhaar_app/core/utils/app_utils.dart';

class BalanceChip extends StatelessWidget {
  final double balance;
  const BalanceChip({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final bool pending = balance > 0;
    final bool advance = balance < 0;

    final Color color = pending ? ColorConstant.primary : ColorConstant.green;
    final String text = pending
        ? AppUtils.formatCurrency(balance)
        : advance
        ? 'Advance ${AppUtils.formatCurrency(balance.abs())}'
        : 'Clear';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_state.dart';
import 'package:udhaar_app/bloc/transaction/transaction_bloc.dart';
import 'package:udhaar_app/core/constants/app_colors.dart';
import 'package:udhaar_app/core/constants/app_dimensions.dart';
import 'package:udhaar_app/core/constants/app_strings.dart';
import 'package:udhaar_app/core/constants/app_styles.dart';
import 'package:udhaar_app/core/extensions/context_extension.dart';
import 'package:udhaar_app/core/utils/app_utils.dart';
import 'package:udhaar_app/core/utils/whatsapp_utils.dart';
import 'package:udhaar_app/data/models/customer_model.dart';
import 'package:udhaar_app/presentations/screens/customer_detail_screen.dart';
import 'package:udhaar_app/presentations/widgets/app_card.dart';
import 'package:udhaar_app/presentations/widgets/customer_tile.dart';
import 'package:udhaar_app/presentations/widgets/empty_view.dart';

class _OverdueItem {
  final CustomerModel customer;
  final double balance;
  final int days;
  final bool hasPaid;

  const _OverdueItem({
    required this.customer,
    required this.balance,
    required this.days,
    required this.hasPaid,
  });
}

class OverdueScreen extends StatelessWidget {
  const OverdueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerState = context.watch<CustomerBloc>().state;
    final txState = context.watch<TransactionBloc>().state;

    final loading = customerState.status == ListStatus.loading ||
        customerState.status == ListStatus.initial ||
        txState.status == ListStatus.loading ||
        txState.status == ListStatus.initial;

    final items = <_OverdueItem>[];
    if (!loading) {
      for (final c in customerState.customers) {
        final days = txState.overdueDaysOf(c.id, StringConstant.overdueDays);
        if (days != null) {
          items.add(_OverdueItem(
            customer: c,
            balance: txState.balanceOf(c.id),
            days: days,
            hasPaid: txState.hasPaid(c.id),
          ));
        }
      }
      items.sort((a, b) => b.days.compareTo(a.days));
    }

    final totalOverdue = items.fold<double>(0, (s, i) => s + i.balance);

    return Scaffold(
      appBar: AppBar(title: const Text('Overdue list')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const EmptyView(
        icon: Icons.check_circle_outline,
        color: ColorConstant.green,
        text: 'No overdue customers.\nEverything looks good!',
      )
          : Align(
          alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(DimensionConstant.padding),
            children: [
              _SummaryBanner(
                  count: items.length, total: totalOverdue),
              const SizedBox(height: 14),
              ...items.map((i) => _OverdueTile(
                item: i,
                onTap: () => context.navigateTo(
                  CustomerDetailScreen(
                      customerId: i.customer.id),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final int count;
  final double total;
  const _SummaryBanner({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DimensionConstant.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConstant.primary,
            Color.lerp(ColorConstant.primary, Colors.black, 0.25)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DimensionConstant.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == 1
                      ? '1 customer overdue'
                      : '$count customers overdue',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total due ${AppUtils.formatCurrency(total)}  •  '
                      'No payment for ${StringConstant.overdueDays}+ days',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverdueTile extends StatelessWidget {
  final _OverdueItem item;
  final VoidCallback onTap;
  const _OverdueTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = item.customer;
    final reason = item.hasPaid
        ? 'No payment for ${item.days} days'
        : 'Credit given ${item.days} days ago, no payment yet';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              InitialAvatar(name: c.name, color: ColorConstant.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleConstant.title),
                    const SizedBox(height: 2),
                    Text(c.phone, style: StyleConstant.caption),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppUtils.formatCurrency(item.balance),
                    style: const TextStyle(
                      color: ColorConstant.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const Text('due', style: StyleConstant.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 16, color: ColorConstant.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(reason,
                    style: StyleConstant.caption
                        .copyWith(color: ColorConstant.primary)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstant.whatsapp,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: () async {
                  final ok = await WhatsAppUtils.sendReminder(
                    phone: c.phone,
                    name: c.name,
                    balance: item.balance,
                  );
                  if (!ok && context.mounted) {
                    context.showSnackBar('Could not open WhatsApp',
                        isError: true);
                  }
                },
                icon: const Icon(Icons.chat, size: 18),
                label: const Text('Remind'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
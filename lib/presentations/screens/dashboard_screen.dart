import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udhaar_app/bloc/auth/auth_bloc.dart';
import 'package:udhaar_app/bloc/auth/auth_event.dart';
import 'package:udhaar_app/bloc/customer/customer_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_state.dart';
import 'package:udhaar_app/bloc/transaction/transaction_bloc.dart';
import 'package:udhaar_app/core/constants/app_colors.dart';
import 'package:udhaar_app/core/constants/app_dimensions.dart';
import 'package:udhaar_app/core/constants/app_strings.dart';
import 'package:udhaar_app/core/constants/app_styles.dart';
import 'package:udhaar_app/core/extensions/context_extension.dart';
import 'package:udhaar_app/core/extensions/date_extension.dart';
import 'package:udhaar_app/core/utils/app_utils.dart';
import 'package:udhaar_app/presentations/screens/customers_screen.dart';
import 'package:udhaar_app/presentations/screens/overdue_screen.dart';
import 'package:udhaar_app/presentations/widgets/app_card.dart';
import 'package:udhaar_app/presentations/widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Do you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out',
                style: TextStyle(color: ColorConstant.primary)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }

  String _plural(int n, String word) => n == 1 ? '$n $word' : '$n ${word}s';

  @override
  Widget build(BuildContext context) {
    final email = context.read<AuthBloc>().state.user?.email ?? '';
    final customerState = context.watch<CustomerBloc>().state;
    final tx = context.watch<TransactionBloc>().state;

    final loading = customerState.status == ListStatus.loading ||
        customerState.status == ListStatus.initial ||
        tx.status == ListStatus.loading ||
        tx.status == ListStatus.initial;

    var overdueCount = 0;
    if (!loading) {
      for (final c in customerState.customers) {
        if (tx.overdueDaysOf(c.id, StringConstant.overdueDays) != null) {
          overdueCount++;
        }
      }
    }

    String money(double v) => loading ? '...' : AppUtils.formatCurrency(v);
    final wide = context.isLargeScreen;

    final hero = SummaryCard(
      big: true,
      title: 'Total outstanding',
      value: money(tx.totalOutstanding),
      subtitle: loading
          ? null
          : tx.pendingCustomersCount == 0
          ? 'No pending balance'
          : '${_plural(tx.pendingCustomersCount, "customer")} owe you money',
      icon: Icons.account_balance_wallet_outlined,
      color: ColorConstant.brand,
    );

    final stats = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SummaryCard(
            title: 'Given today',
            value: money(tx.todayCredit),
            subtitle: 'Credit given',
            icon: Icons.arrow_upward_rounded,
            color: ColorConstant.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryCard(
            title: 'Received today',
            value: money(tx.todayPayment),
            subtitle: 'Payments received',
            icon: Icons.arrow_downward_rounded,
            color: ColorConstant.green,
          ),
        ),
      ],
    );

    final navs = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavTile(
          icon: Icons.people_alt_rounded,
          color: ColorConstant.brand,
          title: 'Customers',
          subtitle: loading
              ? 'Loading...'
              : _plural(customerState.customers.length, 'customer'),
          onTap: () => context.navigateTo(const CustomersScreen()),
        ),
        const SizedBox(height: 12),
        _NavTile(
          icon: Icons.warning_amber_rounded,
          color: ColorConstant.primary,
          title: 'Overdue list',
          subtitle: loading
              ? 'Loading...'
              : overdueCount == 0
              ? 'No overdue customers'
              : '${_plural(overdueCount, "customer")} need a reminder',
          badge: overdueCount,
          onTap: () => context.navigateTo(const OverdueScreen()),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: ColorConstant.brandGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(StringConstant.appName),
          ],
        ),
        actions: [
          IconButton(
            tooltip: StringConstant.logout,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _confirmLogout(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(wide ? 24 : DimensionConstant.padding),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 1000 : 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's summary", style: StyleConstant.heading),
                const SizedBox(height: 2),
                Text('${DateTime.now().formatted}  •  $email',
                    style: StyleConstant.caption),
                const SizedBox(height: 18),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [hero, const SizedBox(height: 12), stats],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: navs),
                    ],
                  )
                else
                  Column(
                    children: [
                      hero,
                      const SizedBox(height: 12),
                      stats,
                      const SizedBox(height: 20),
                      navs,
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final int badge;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: StyleConstant.title),
                const SizedBox(height: 2),
                Text(subtitle, style: StyleConstant.caption),
              ],
            ),
          ),
          if (badge > 0)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$badge',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          const Icon(Icons.chevron_right, color: ColorConstant.textGrey),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_event.dart';
import 'package:udhaar_app/bloc/customer/customer_state.dart';
import 'package:udhaar_app/bloc/transaction/transaction_bloc.dart';
import 'package:udhaar_app/bloc/transaction/transaction_event.dart';
import 'package:udhaar_app/bloc/transaction/transaction_state.dart';
import 'package:udhaar_app/core/constants/app_colors.dart';
import 'package:udhaar_app/core/constants/app_dimensions.dart';
import 'package:udhaar_app/core/constants/app_strings.dart';
import 'package:udhaar_app/core/constants/app_styles.dart';
import 'package:udhaar_app/core/extensions/context_extension.dart';
import 'package:udhaar_app/core/extensions/date_extension.dart';
import 'package:udhaar_app/core/utils/app_utils.dart';
import 'package:udhaar_app/core/utils/whatsapp_utils.dart';
import 'package:udhaar_app/data/models/customer_model.dart';
import 'package:udhaar_app/data/models/transaction_model.dart';
import 'package:udhaar_app/presentations/screens/add_entry_screen.dart';
import 'package:udhaar_app/presentations/screens/customer_form_screen.dart';
import 'package:udhaar_app/presentations/widgets/app_card.dart';
import 'package:udhaar_app/presentations/widgets/customer_tile.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool _deleting = false;
  bool _deletingTx = false;

  Future<bool> _askConfirm(String title, String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: ColorConstant.primary)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _confirmDelete(CustomerModel c) async {
    final ok = await _askConfirm(
      'Delete customer?',
      '"${c.name}" and all their entries will be deleted. This cannot be undone.',
    );
    if (ok && mounted) {
      _deleting = true;
      context.read<CustomerBloc>().add(CustomerDeleteRequested(c.id));
    }
  }

  Future<void> _confirmDeleteTx(TransactionModel t) async {
    final ok = await _askConfirm(
      'Delete entry?',
      'Delete this ${t.isCredit ? "credit" : "payment"} of ${AppUtils.formatCurrency(t.amount)}?',
    );
    if (ok && mounted) {
      _deletingTx = true;
      context.read<TransactionBloc>().add(TransactionDeleteRequested(t.id));
    }
  }

  void _openEntry(CustomerModel c, String type) {
    context.navigateTo(AddEntryScreen(
      customerId: c.id,
      customerName: c.name,
      type: type,
    ));
  }

  Future<void> _sendReminder(CustomerModel c, double balance) async {
    final ok = await WhatsAppUtils.sendReminder(
      phone: c.phone,
      name: c.name,
      balance: balance,
    );
    if (!ok && mounted) {
      context.showSnackBar('Could not open WhatsApp', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CustomerBloc, CustomerState>(
          listenWhen: (p, c) => p.actionStatus != c.actionStatus && _deleting,
          listener: (context, state) {
            if (state.actionStatus == ActionStatus.success) {
              context.showSnackBar(state.actionMessage ?? 'Done');
              context.goBack();
            } else if (state.actionStatus == ActionStatus.failure) {
              _deleting = false;
              context.showSnackBar(state.actionMessage ?? 'Error',
                  isError: true);
            }
          },
        ),
        BlocListener<TransactionBloc, TransactionState>(
          listenWhen: (p, c) => p.actionStatus != c.actionStatus && _deletingTx,
          listener: (context, state) {
            if (state.actionStatus == ActionStatus.success) {
              _deletingTx = false;
              context.showSnackBar(state.actionMessage ?? 'Done');
            } else if (state.actionStatus == ActionStatus.failure) {
              _deletingTx = false;
              context.showSnackBar(state.actionMessage ?? 'Error',
                  isError: true);
            }
          },
        ),
      ],
      child: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          final c = state.byId(widget.customerId);

          if (c == null) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          final wide = context.isLargeScreen;

          return Scaffold(
            appBar: AppBar(
              title: Text(c.name),
              actions: [
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () =>
                      context.navigateTo(CustomerFormScreen(customer: c)),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline,
                      color: ColorConstant.primary),
                  onPressed: () => _confirmDelete(c),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, tx) {
                final balance = tx.balanceOf(c.id);
                final history = tx.forCustomer(c.id);

                final summary = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BalanceCard(
                      balance: balance,
                      totalCredit: tx.totalCreditOf(c.id),
                      totalPayment: tx.totalPaymentOf(c.id),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Give Credit',
                            icon: Icons.arrow_upward_rounded,
                            color: ColorConstant.primary,
                            onTap: () => _openEntry(c, StringConstant.credit),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: 'Receive Payment',
                            icon: Icons.arrow_downward_rounded,
                            color: ColorConstant.green,
                            onTap: () => _openEntry(c, StringConstant.payment),
                          ),
                        ),
                      ],
                    ),
                    if (balance > 0) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstant.whatsapp,
                        ),
                        onPressed: () => _sendReminder(c, balance),
                        icon: const Icon(Icons.chat, size: 20),
                        label: const Text('Send WhatsApp Reminder'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _InfoCard(customer: c),
                  ],
                );

                final historyView = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Text('History', style: StyleConstant.title),
                        const SizedBox(width: 8),
                        if (history.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: ColorConstant.brand.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('${history.length}',
                                style: const TextStyle(
                                    color: ColorConstant.brand,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (history.isEmpty)
                      const AppCard(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text('No entries yet.',
                                style: StyleConstant.caption),
                          ),
                        ),
                      )
                    else
                      ...history.map(
                            (t) => _TransactionTile(
                          t: t,
                          onDelete: () => _confirmDeleteTx(t),
                        ),
                      ),
                  ],
                );

                return SingleChildScrollView(
                  padding:
                  EdgeInsets.all(wide ? 24 : DimensionConstant.padding),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: wide
                              ? DimensionConstant.maxWideWidth
                              : DimensionConstant.maxContentWidth),
                      child: wide
                          ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 400, child: summary),
                          const SizedBox(width: 24),
                          Expanded(child: historyView),
                        ],
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          summary,
                          const SizedBox(height: 20),
                          historyView,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final double totalCredit;
  final double totalPayment;

  const _BalanceCard({
    required this.balance,
    required this.totalCredit,
    required this.totalPayment,
  });

  @override
  Widget build(BuildContext context) {
    final pending = balance > 0;
    final color = pending ? ColorConstant.primary : ColorConstant.green;
    final label = pending
        ? 'Amount due'
        : balance < 0
        ? 'Advance (paid extra)'
        : 'All clear';

    return Container(
      padding: const EdgeInsets.all(DimensionConstant.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, 0.25)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DimensionConstant.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppUtils.formatCurrency(balance.abs()),
              style: StyleConstant.balanceBig
                  .copyWith(color: Colors.white, fontSize: 40),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _MiniStat('Total credit', totalCredit)),
                Container(width: 1, height: 28, color: Colors.white30),
                Expanded(child: _MiniStat('Total paid', totalPayment)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  const _MiniStat(this.label, this.amount);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          AppUtils.formatCurrency(amount),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final CustomerModel customer;
  const _InfoCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialAvatar(name: customer.name, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Text(customer.name,
                    style: StyleConstant.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Divider(height: 24, color: ColorConstant.border),
          _InfoRow(Icons.phone_outlined, customer.phone),
          if (customer.address.isNotEmpty)
            _InfoRow(Icons.location_on_outlined, customer.address),
          _InfoRow(Icons.calendar_today_outlined,
              'Added on ${customer.createdAt.formatted}'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 19, color: ColorConstant.textGrey),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: StyleConstant.body)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel t;
  final VoidCallback onDelete;
  const _TransactionTile({required this.t, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = t.isCredit ? ColorConstant.primary : ColorConstant.green;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              t.isCredit
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.isCredit ? 'Credit given' : 'Payment received',
                    style: StyleConstant.title.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  t.note.isEmpty
                      ? t.date.formatted
                      : '${t.date.formatted}  •  ${t.note}',
                  style: StyleConstant.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${t.isCredit ? "+" : "-"} ${AppUtils.formatCurrency(t.amount)}',
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 15),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.close, size: 18),
            color: ColorConstant.textGrey,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
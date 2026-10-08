import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_state.dart';
import 'package:udhaar_app/bloc/transaction/transaction_bloc.dart';
import 'package:udhaar_app/bloc/transaction/transaction_event.dart';
import 'package:udhaar_app/bloc/transaction/transaction_state.dart';
import 'package:udhaar_app/core/constants/app_colors.dart';
import 'package:udhaar_app/core/constants/app_strings.dart';
import 'package:udhaar_app/core/extensions/context_extension.dart';
import 'package:udhaar_app/core/extensions/date_extension.dart';
import 'package:udhaar_app/data/models/transaction_model.dart';
import 'package:udhaar_app/presentations/widgets/app_card.dart';
import 'package:udhaar_app/presentations/widgets/app_text_field.dart';
import '../../core/constants/app_dimensions.dart' show DimensionConstant;

class AddEntryScreen extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String type;

  const AddEntryScreen({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.type,
  });

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  bool get _isCredit => widget.type == StringConstant.credit;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    context.dismissKeyboard();
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountCtrl.text.replaceAll(',', '').trim());
    final now = DateTime.now();
    final date =
    DateTime(_date.year, _date.month, _date.day, now.hour, now.minute);

    context.read<TransactionBloc>().add(TransactionAddRequested(
      TransactionModel(
        id: '',
        customerId: widget.customerId,
        type: widget.type,
        amount: amount,
        note: _noteCtrl.text.trim(),
        date: date,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final color = _isCredit ? ColorConstant.primary : ColorConstant.green;

    return BlocConsumer<TransactionBloc, TransactionState>(
      listenWhen: (p, c) => p.actionStatus != c.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == ActionStatus.success) {
          context.showSnackBar(state.actionMessage ?? 'Done');
          context.goBack();
        } else if (state.actionStatus == ActionStatus.failure) {
          context.showSnackBar(state.actionMessage ?? 'Error', isError: true);
        }
      },
      builder: (context, state) {
        final saving = state.actionStatus == ActionStatus.saving;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isCredit ? 'Give Credit' : 'Receive Payment'),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DimensionConstant.padding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DimensionConstant.padding),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius:
                        BorderRadius.circular(DimensionConstant.radius),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                            child: Icon(
                              _isCredit
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isCredit
                                  ? 'Giving credit to ${widget.customerName}'
                                  : 'Receiving payment from ${widget.customerName}',
                              style: TextStyle(
                                  color: color, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      padding:
                      const EdgeInsets.all(DimensionConstant.paddingLarge),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              controller: _amountCtrl,
                              label: 'Amount (${StringConstant.currency})',
                              icon: Icons.payments_outlined,
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                final n = double.tryParse(
                                    (v ?? '').replaceAll(',', '').trim());
                                if (n == null || n <= 0) {
                                  return 'Enter a valid amount';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                for (final v in [500, 1000, 2000, 5000])
                                  ActionChip(
                                    label: Text('$v'),
                                    onPressed: () => _amountCtrl.text = '$v',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              controller: _noteCtrl,
                              label: 'Note (optional)',
                              icon: Icons.notes_outlined,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(
                                  DimensionConstant.radius),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  prefixIcon:
                                  Icon(Icons.calendar_today_outlined),
                                ),
                                child: Text(_date.formatted),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: color),
                              onPressed: saving ? null : _save,
                              child: saving
                                  ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                                  : const Text('Save'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
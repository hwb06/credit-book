import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_event.dart';
import 'package:udhaar_app/bloc/customer/customer_state.dart';
import 'package:udhaar_app/core/constants/app_dimensions.dart';
import 'package:udhaar_app/core/extensions/context_extension.dart';
import 'package:udhaar_app/core/extensions/string_extension.dart';
import 'package:udhaar_app/data/models/customer_model.dart';
import 'package:udhaar_app/presentations/widgets/app_card.dart';
import 'package:udhaar_app/presentations/widgets/app_text_field.dart';

class CustomerFormScreen extends StatefulWidget {
  final CustomerModel? customer;
  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;

  bool get _isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.customer?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.customer?.phone ?? '');
    _addressCtrl = TextEditingController(text: widget.customer?.address ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _save() {
    context.dismissKeyboard();
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<CustomerBloc>();
    if (_isEdit) {
      bloc.add(CustomerUpdateRequested(widget.customer!.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      )));
    } else {
      bloc.add(CustomerAddRequested(CustomerModel(
        id: '',
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        createdAt: DateTime.now(),
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerBloc, CustomerState>(
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
            title: Text(_isEdit ? 'Edit customer' : 'New customer'),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DimensionConstant.padding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: AppCard(
                  padding: const EdgeInsets.all(DimensionConstant.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _nameCtrl,
                          label: 'Name',
                          icon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().length < 2)
                              ? 'Enter the customer name'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _phoneCtrl,
                          label: 'Phone (+923001234567)',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || !v.isValidPhone)
                              ? 'Enter a valid phone number'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _addressCtrl,
                          label: 'Address (optional)',
                          icon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: saving ? null : _save,
                          child: saving
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : Text(_isEdit ? 'Update' : 'Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
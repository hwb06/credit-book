import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udhaar_app/bloc/auth/auth_bloc.dart';
import 'package:udhaar_app/bloc/auth/auth_event.dart';
import 'package:udhaar_app/bloc/auth/auth_state.dart';
import 'package:udhaar_app/core/constants/app_colors.dart';
import 'package:udhaar_app/core/constants/app_dimensions.dart';
import 'package:udhaar_app/core/constants/app_strings.dart';
import 'package:udhaar_app/core/constants/app_styles.dart';
import 'package:udhaar_app/core/extensions/context_extension.dart';
import 'package:udhaar_app/core/extensions/string_extension.dart';
import 'package:udhaar_app/presentations/widgets/app_card.dart';
import 'package:udhaar_app/presentations/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.dismissKeyboard();
    if (_formKey.currentState!.validate()) {
      context
          .read<AuthBloc>()
          .add(AuthLoginRequested(_emailCtrl.text, _passCtrl.text));
    }
  }

  Widget _buildForm(bool loading) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Welcome back', style: StyleConstant.heading),
          const SizedBox(height: 4),
          const Text('Log in to manage your credit book',
              style: StyleConstant.caption),
          const SizedBox(height: 24),
          AppTextField(
            controller: _emailCtrl,
            label: StringConstant.email,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email';
              if (!v.isValidEmail) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _passCtrl,
            label: StringConstant.password,
            icon: Icons.lock_outline,
            obscure: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (v) =>
            (v == null || v.length < 6) ? 'At least 6 characters' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: loading ? null : _submit,
            child: loading
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : const Text(StringConstant.login),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          context.showSnackBar(state.error ?? 'Login failed', isError: true);
        }
      },
      builder: (context, state) {
        final loading = state.status == AuthStatus.loading;

        if (context.isLargeScreen) {
          return Scaffold(
            body: Row(
              children: [
                const Expanded(flex: 5, child: _BrandPanel()),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildForm(loading),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration:
            const BoxDecoration(gradient: ColorConstant.brandGradient),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(DimensionConstant.padding),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.menu_book_rounded,
                              size: 44, color: Colors.white),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          StringConstant.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppCard(
                          padding:
                          const EdgeInsets.all(DimensionConstant.paddingLarge),
                          child: _buildForm(loading),
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

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    Widget point(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white70, size: 22),
          const SizedBox(width: 12),
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );

    return Container(
      decoration: const BoxDecoration(gradient: ColorConstant.brandGradient),
      padding: const EdgeInsets.all(56),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book_rounded,
                size: 48, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            StringConstant.appName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your digital khata. Simple, fast and always with you.',
            style: TextStyle(color: Colors.white70, fontSize: 17),
          ),
          const SizedBox(height: 40),
          point('Track credit and payments'),
          point('See every customer balance instantly'),
          point('Send WhatsApp reminders in one tap'),
        ],
      ),
    );
  }
}
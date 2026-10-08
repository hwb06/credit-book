import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udhaar_app/bloc/auth/auth_bloc.dart';
import 'package:udhaar_app/bloc/auth/auth_state.dart';
import 'package:udhaar_app/bloc/customer/customer_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_event.dart';
import 'package:udhaar_app/bloc/transaction/transaction_bloc.dart';
import 'package:udhaar_app/bloc/transaction/transaction_event.dart';
import 'package:udhaar_app/core/constants/app_strings.dart';
import 'package:udhaar_app/data/repositories/auth_repository.dart';
import 'package:udhaar_app/data/repositories/customer_repository.dart';
import 'package:udhaar_app/data/repositories/transaction_repository.dart';
import 'package:udhaar_app/firebase_options.dart';
import 'core/constants/theme.dart';
import 'presentations/screens/dashboard_screen.dart';
import 'presentations/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const UdhaarApp());
}

class UdhaarApp extends StatelessWidget {
  const UdhaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => CustomerRepository()),
        RepositoryProvider(create: (_) => TransactionRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (c) => AuthBloc(c.read<AuthRepository>())),
          BlocProvider(
              create: (c) => CustomerBloc(c.read<CustomerRepository>())),
          BlocProvider(
              create: (c) => TransactionBloc(c.read<TransactionRepository>())),
        ],
        child: MaterialApp(
          title: StringConstant.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) =>
      p.status != c.status &&
          (c.status == AuthStatus.authenticated ||
              c.status == AuthStatus.unauthenticated),
      listener: (context, state) {
        final customers = context.read<CustomerBloc>();
        final transactions = context.read<TransactionBloc>();
        if (state.status == AuthStatus.authenticated) {
          customers.add(const CustomersStarted());
          transactions.add(const TransactionsStarted());
        } else {
          customers.add(const CustomersCleared());
          transactions.add(const TransactionsCleared());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.authenticated:
              return const DashboardScreen();
            case AuthStatus.unknown:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            default:
              return const LoginScreen();
          }
        },
      ),
    );
  }
}
import 'package:equatable/equatable.dart';
import 'package:udhaar_app/bloc/customer/customer_state.dart';
import 'package:udhaar_app/data/models/transaction_model.dart';
import 'package:udhaar_app/core/extensions/date_extension.dart';


class TransactionState extends Equatable {
  final ListStatus status;
  final List<TransactionModel> transactions;
  final Map<String, double> balances;
  final String? error;
  final ActionStatus actionStatus;
  final String? actionMessage;

  const TransactionState({
    this.status = ListStatus.initial,
    this.transactions = const [],
    this.balances = const {},
    this.error,
    this.actionStatus = ActionStatus.idle,
    this.actionMessage,
  });

  double balanceOf(String customerId) => balances[customerId] ?? 0;

  List<TransactionModel> forCustomer(String customerId) =>
      transactions.where((t) => t.customerId == customerId).toList();

  double totalCreditOf(String customerId) => transactions
      .where((t) => t.customerId == customerId && t.isCredit)
      .fold(0.0, (s, t) => s + t.amount);

  double totalPaymentOf(String customerId) => transactions
      .where((t) => t.customerId == customerId && t.isPayment)
      .fold(0.0, (s, t) => s + t.amount);

  int? overdueDaysOf(String customerId, int limitDays) {
    if (balanceOf(customerId) <= 0) return null;

    final mine = forCustomer(customerId);
    if (mine.isEmpty) return null;

    final payments = mine.where((t) => t.isPayment).toList();

    DateTime reference;
    if (payments.isNotEmpty) {
      reference =
          payments.map((t) => t.date).reduce((a, b) => a.isAfter(b) ? a : b);
    } else {
      reference = mine.map((t) => t.date).reduce((a, b) => a.isBefore(b) ? a : b);
    }

    final days =
        DateTime.now().startOfDay.difference(reference.startOfDay).inDays;
    return days >= limitDays ? days : null;
  }

  bool hasPaid(String customerId) =>
      transactions.any((t) => t.customerId == customerId && t.isPayment);

  double get todayCredit => transactions
      .where((t) => t.isCredit && t.date.isToday)
      .fold(0.0, (s, t) => s + t.amount);

  double get todayPayment => transactions
      .where((t) => t.isPayment && t.date.isToday)
      .fold(0.0, (s, t) => s + t.amount);

  double get totalOutstanding =>
      balances.values.where((b) => b > 0).fold(0.0, (s, b) => s + b);

  int get pendingCustomersCount => balances.values.where((b) => b > 0).length;

  TransactionState copyWith({
    ListStatus? status,
    List<TransactionModel>? transactions,
    Map<String, double>? balances,
    String? error,
    ActionStatus? actionStatus,
    String? actionMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      balances: balances ?? this.balances,
      error: error,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, transactions, balances, error, actionStatus, actionMessage];
}
import 'package:equatable/equatable.dart';
import 'package:udhaar_app/data/models/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsStarted extends TransactionEvent {
  const TransactionsStarted();
}

class TransactionsCleared extends TransactionEvent {
  const TransactionsCleared();
}

class TransactionsUpdated extends TransactionEvent {
  final List<TransactionModel> transactions;
  const TransactionsUpdated(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionsFailed extends TransactionEvent {
  final String error;
  const TransactionsFailed(this.error);

  @override
  List<Object?> get props => [error];
}

class TransactionAddRequested extends TransactionEvent {
  final TransactionModel transaction;
  const TransactionAddRequested(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleteRequested extends TransactionEvent {
  final String id;
  const TransactionDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
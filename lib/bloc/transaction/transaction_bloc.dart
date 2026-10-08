import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_state.dart';
import 'package:udhaar_app/bloc/transaction/transaction_event.dart';
import 'package:udhaar_app/bloc/transaction/transaction_state.dart';
import 'package:udhaar_app/data/models/transaction_model.dart';
import 'package:udhaar_app/data/repositories/transaction_repository.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repo;
  StreamSubscription<List<TransactionModel>>? _sub;

  TransactionBloc(this._repo) : super(const TransactionState()) {
    on<TransactionsStarted>(_onStarted);
    on<TransactionsCleared>(_onCleared);
    on<TransactionsUpdated>(_onUpdated);
    on<TransactionsFailed>(
          (e, emit) =>
          emit(state.copyWith(status: ListStatus.failure, error: e.error)),
    );
    on<TransactionAddRequested>(_onAdd);
    on<TransactionDeleteRequested>(_onDelete);
  }

  Future<void> _onStarted(
      TransactionsStarted event,
      Emitter<TransactionState> emit,
      ) async {
    emit(state.copyWith(status: ListStatus.loading));
    await _sub?.cancel();
    _sub = _repo.watchAll().listen(
          (list) => add(TransactionsUpdated(list)),
      onError: (e) => add(TransactionsFailed(e.toString())),
    );
  }

  Future<void> _onCleared(
      TransactionsCleared event,
      Emitter<TransactionState> emit,
      ) async {
    await _sub?.cancel();
    _sub = null;
    emit(const TransactionState());
  }

  void _onUpdated(
      TransactionsUpdated event,
      Emitter<TransactionState> emit,
      ) {
    final balances = <String, double>{};
    for (final t in event.transactions) {
      final sign = t.isCredit ? 1 : -1;
      balances[t.customerId] = (balances[t.customerId] ?? 0) + sign * t.amount;
    }
    emit(state.copyWith(
      status: ListStatus.loaded,
      transactions: event.transactions,
      balances: balances,
    ));
  }

  Future<void> _onAdd(
      TransactionAddRequested event,
      Emitter<TransactionState> emit,
      ) async {
    emit(state.copyWith(actionStatus: ActionStatus.saving));
    try {
      await _repo.addTransaction(event.transaction);
      emit(state.copyWith(
        actionStatus: ActionStatus.success,
        actionMessage: event.transaction.isCredit
            ? 'Credit recorded'
            : 'Payment recorded',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: ActionStatus.failure,
        actionMessage: 'Could not save entry',
      ));
    }
  }

  Future<void> _onDelete(
      TransactionDeleteRequested event,
      Emitter<TransactionState> emit,
      ) async {
    emit(state.copyWith(actionStatus: ActionStatus.saving));
    try {
      await _repo.deleteTransaction(event.id);
      emit(state.copyWith(
        actionStatus: ActionStatus.success,
        actionMessage: 'Entry deleted',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: ActionStatus.failure,
        actionMessage: 'Could not delete entry',
      ));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
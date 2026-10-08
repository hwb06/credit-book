import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_event.dart';
import 'package:udhaar_app/bloc/customer/customer_state.dart';
import 'package:udhaar_app/data/models/customer_model.dart';
import 'package:udhaar_app/data/repositories/customer_repository.dart';

class CustomerBloc extends Bloc< CustomerEvent, CustomerState> {
  final CustomerRepository _repo;
  StreamSubscription<List<CustomerModel>>? _sub;

  CustomerBloc(this._repo) : super(const CustomerState()) {
    on<CustomersStarted>(_onStarted);
    on<CustomersCleared>(_onCleared);
    on<CustomersUpdated>(
          (e, emit) => emit(state.copyWith(
        status: ListStatus.loaded,
        customers: e.customers,
      )),
    );
    on<CustomersFailed>(
          (e, emit) =>
          emit(state.copyWith(status: ListStatus.failure, error: e.error)),
    );
    on<CustomersSearchChanged>(
          (e, emit) => emit(state.copyWith(query: e.query)),
    );
    on<CustomerAddRequested>(_onAdd);
    on<CustomerUpdateRequested>(_onUpdate);
    on<CustomerDeleteRequested>(_onDelete);
  }

  Future<void> _onStarted(
      CustomersStarted event,
      Emitter<CustomerState> emit,
      ) async {
    emit(state.copyWith(status: ListStatus.loading));
    await _sub?.cancel();
    _sub = _repo.watchCustomers().listen(
          (list) => add(CustomersUpdated(list)),
      onError: (e) => add(CustomersFailed(e.toString())),
    );
  }

  Future<void> _onCleared(
      CustomersCleared event,
      Emitter<CustomerState> emit,
      ) async {
    await _sub?.cancel();
    _sub = null;
    emit(const CustomerState());
  }

  Future<void> _onAdd(
      CustomerAddRequested event,
      Emitter<CustomerState> emit,
      ) async {
    emit(state.copyWith(actionStatus: ActionStatus.saving));
    try {
      await _repo.addCustomer(event.customer);
      emit(state.copyWith(
        actionStatus: ActionStatus.success,
        actionMessage: 'Customer added',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: ActionStatus.failure,
        actionMessage: 'Could not add customer',
      ));
    }
  }

  Future<void> _onUpdate(
      CustomerUpdateRequested event,
      Emitter<CustomerState> emit,
      ) async {
    emit(state.copyWith(actionStatus: ActionStatus.saving));
    try {
      await _repo.updateCustomer(event.customer);
      emit(state.copyWith(
        actionStatus: ActionStatus.success,
        actionMessage: 'Customer updated',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: ActionStatus.failure,
        actionMessage: 'Could not update customer',
      ));
    }
  }

  Future<void> _onDelete(
      CustomerDeleteRequested event,
      Emitter<CustomerState> emit,
      ) async {
    emit(state.copyWith(actionStatus: ActionStatus.saving));
    try {
      await _repo.deleteCustomer(event.id);
      emit(state.copyWith(
        actionStatus: ActionStatus.success,
        actionMessage: 'Customer deleted',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: ActionStatus.failure,
        actionMessage: 'Could not delete customer',
      ));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
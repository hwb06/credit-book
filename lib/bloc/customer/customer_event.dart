import 'package:equatable/equatable.dart';
import 'package:udhaar_app/data/models/customer_model.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class CustomersStarted extends CustomerEvent {
  const CustomersStarted();
}

class CustomersCleared extends CustomerEvent {
  const CustomersCleared();
}

class CustomersUpdated extends CustomerEvent {
  final List<CustomerModel> customers;
  const CustomersUpdated(this.customers);

  @override
  List<Object?> get props => [customers];
}

class CustomersFailed extends CustomerEvent {
  final String error;
  const CustomersFailed(this.error);

  @override
  List<Object?> get props => [error];
}

class CustomersSearchChanged extends CustomerEvent {
  final String query;
  const CustomersSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class CustomerAddRequested extends CustomerEvent {
  final CustomerModel customer;
  const CustomerAddRequested(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerUpdateRequested extends CustomerEvent {
  final CustomerModel customer;
  const CustomerUpdateRequested(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerDeleteRequested extends CustomerEvent {
  final String id;
  const CustomerDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
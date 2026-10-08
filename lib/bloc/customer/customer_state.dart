import 'package:equatable/equatable.dart';
import 'package:udhaar_app/data/models/customer_model.dart';

enum ListStatus { initial, loading, loaded, failure }

enum ActionStatus { idle, saving, success, failure }

class CustomerState extends Equatable {
  final ListStatus status;
  final List<CustomerModel> customers;
  final String query;
  final String? error;
  final ActionStatus actionStatus;
  final String? actionMessage;

  const CustomerState({
    this.status = ListStatus.initial,
    this.customers = const [],
    this.query = '',
    this.error,
    this.actionStatus = ActionStatus.idle,
    this.actionMessage,
  });

  // Search: naam ya phone number se
  List<CustomerModel> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return customers;
    final qDigits = q.replaceAll(RegExp(r'[^0-9]'), '');
    return customers.where((c) {
      final nameMatch = c.name.toLowerCase().contains(q);
      final phoneMatch = qDigits.isNotEmpty &&
          c.phone.replaceAll(RegExp(r'[^0-9]'), '').contains(qDigits);
      return nameMatch || phoneMatch;
    }).toList();
  }

  CustomerModel? byId(String id) {
    for (final c in customers) {
      if (c.id == id) return c;
    }
    return null;
  }

  CustomerState copyWith({
    ListStatus? status,
    List<CustomerModel>? customers,
    String? query,
    String? error,
    ActionStatus? actionStatus,
    String? actionMessage,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      query: query ?? this.query,
      error: error,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, customers, query, error, actionStatus, actionMessage];
}
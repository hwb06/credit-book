import 'package:udhaar_app/data/data_sources/remote/customer_remote_service.dart';
import 'package:udhaar_app/data/models/customer_model.dart';

class CustomerRepository {
  final CustomerRemoteService _service;

  CustomerRepository({CustomerRemoteService? service})
      : _service = service ?? CustomerRemoteService();

  Stream<List<CustomerModel>> watchCustomers() => _service.watchCustomers();

  Future<void> addCustomer(CustomerModel c) => _service.add(c);

  Future<void> updateCustomer(CustomerModel c) => _service.update(c);

  Future<void> deleteCustomer(String id) => _service.delete(id);
}
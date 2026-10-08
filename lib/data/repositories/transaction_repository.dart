import 'package:udhaar_app/data/data_sources/remote/transaction_remote_service.dart';
import 'package:udhaar_app/data/models/transaction_model.dart';

class TransactionRepository {
  final TransactionRemoteService _service;

  TransactionRepository({TransactionRemoteService? service})
      : _service = service ?? TransactionRemoteService();

  Stream<List<TransactionModel>> watchAll() => _service.watchAll();

  Future<void> addTransaction(TransactionModel t) => _service.add(t);

  Future<void> deleteTransaction(String id) => _service.delete(id);
}
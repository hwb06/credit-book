import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:udhaar_app/core/constants/app_strings.dart';

class TransactionModel extends Equatable {
  final String id;
  final String customerId;
  final String type;
  final double amount;
  final String note;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    this.note = '',
    required this.date,
  });

  bool get isCredit => type == StringConstant.credit;
  bool get isPayment => type == StringConstant.payment;

  factory TransactionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return TransactionModel(
      id: doc.id,
      customerId: d['customerId'] ?? '',
      type: d['type'] ?? StringConstant.credit,
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      note: d['note'] ?? '',
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'customerId': customerId,
    'type': type,
    'amount': amount,
    'note': note,
    'date': Timestamp.fromDate(date),
  };

  @override
  List<Object?> get props => [id, customerId, type, amount, note, date];
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udhaar_app/core/constants/app_strings.dart';
import 'package:udhaar_app/data/models/transaction_model.dart';

class TransactionRemoteService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  TransactionRemoteService({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _col {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Please log in first.');
    return _db
        .collection(StringConstant.usersCollection)
        .doc(uid)
        .collection(StringConstant.transactionsCollection);
  }

  Stream<List<TransactionModel>> watchAll() {
    return _col.snapshots().map((snap) {
      final list = snap.docs.map(TransactionModel.fromDoc).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<void> add(TransactionModel t) => _col.add(t.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();
}

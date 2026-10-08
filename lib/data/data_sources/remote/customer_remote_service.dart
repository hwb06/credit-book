import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udhaar_app/core/constants/app_strings.dart';
import 'package:udhaar_app/data/models/customer_model.dart';

class CustomerRemoteService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CustomerRemoteService({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Please log in first.');
    return uid;
  }

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection(StringConstant.usersCollection).doc(_uid);

  CollectionReference<Map<String, dynamic>> get _col =>
      _userDoc.collection(StringConstant.customersCollection);

  Stream<List<CustomerModel>> watchCustomers() {
    return _col.snapshots().map((snap) {
      final list = snap.docs.map(CustomerModel.fromDoc).toList();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  Future<void> add(CustomerModel c) => _col.add(c.toMap());

  Future<void> update(CustomerModel c) => _col.doc(c.id).update({
    'name': c.name,
    'phone': c.phone,
    'address': c.address,
  });

  Future<void> delete(String id) async {
    final txSnap =
        await _userDoc
            .collection(StringConstant.transactionsCollection)
            .where('customerId', isEqualTo: id)
            .get();

    final refs = <DocumentReference>[
      ...txSnap.docs.map((d) => d.reference),
      _col.doc(id),
    ];

    for (var i = 0; i < refs.length; i += 400) {
      final batch = _db.batch();
      final end = (i + 400 > refs.length) ? refs.length : i + 400;
      for (final r in refs.sublist(i, end)) {
        batch.delete(r);
      }
      await batch.commit();
    }
  }
}

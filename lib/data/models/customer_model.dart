import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CustomerModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String address;
  final DateTime createdAt;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.address = '',
    required this.createdAt,
  });

  factory CustomerModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return CustomerModel(
      id: doc.id,
      name: d['name'] ?? '',
      phone: d['phone'] ?? '',
      address: d['address'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'address': address,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  CustomerModel copyWith({String? name, String? phone, String? address}) {
    return CustomerModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, address, createdAt];
}
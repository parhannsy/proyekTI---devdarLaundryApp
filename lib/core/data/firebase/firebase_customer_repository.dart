import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';
import '../../repositories/customer_repository.dart';

/// Implementasi [CustomerRepository] menggunakan Cloud Firestore.
///
/// Pagination menggunakan cursor-based `startAfterDocument()` dengan
/// default ordering document ID — TIDAK membutuhkan composite index.
/// Stream menggunakan `.snapshots()` untuk realtime update.
class FirebaseCustomerRepository implements CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Query get _baseQuery => _firestore
      .collection('users')
      .where('role', isEqualTo: 'customer')
      .orderBy(FieldPath.documentId);

  @override
  Future<List<UserModel>> getAllCustomers() async {
    final snapshot = await _baseQuery.get();
    final customers =
        snapshot.docs.map((doc) => _userFromDoc(doc)).toList();
    customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return customers;
  }

  @override
  Future<CustomerPageResult> getCustomersPage({
    required int limit,
    Object? cursor,
  }) async {
    Query query = _baseQuery.limit(limit);

    if (cursor != null) {
      query = query.startAfterDocument(cursor as DocumentSnapshot);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;
    final hasMore = docs.length >= limit;

    final customers =
        docs.map((doc) => _userFromDoc(doc)).toList();

    return CustomerPageResult(
      customers: customers,
      hasMore: hasMore,
      cursor: docs.isNotEmpty ? docs.last : null,
    );
  }

  @override
  Stream<List<UserModel>> streamCustomers() {
    return _baseQuery.snapshots().map((snapshot) {
      final customers = snapshot.docs
          .map((doc) => _userFromDoc(doc))
          .toList();
      customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return customers;
    });
  }

  @override
  Future<UserModel?> getCustomerById(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (!doc.exists) return null;
    return _userFromDoc(doc);
  }

  @override
  Future<UserModel> updateCustomer(UserModel customer) async {
    await _firestore.collection('users').doc(customer.id).update({
      'name': customer.name,
      'email': customer.email,
      'phone': customer.phone,
      'loyaltyPoints': customer.loyaltyPoints,
      'totalSavings': customer.totalSavings,
    });
    return customer;
  }

  @override
  Future<void> deactivateCustomer(String id) async {
    await _firestore.collection('users').doc(id).update({
      'isActive': false,
    });
  }

  /// Parse addresses dari Firestore, dengan fallback ke field 'address' lama.
  List<AddressModel> _parseAddresses(Map<String, dynamic> data) {
    final list = (data['addresses'] as List<dynamic>?)
        ?.map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
        .toList();
    if (list != null && list.isNotEmpty) return list;
    if (data['address'] != null && (data['address'] as String).isNotEmpty) {
      return [AddressModel(address: data['address'], label: 'Utama', isDefault: true)];
    }
    return [];
  }

  UserModel _userFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      nickname: data['nickname'],
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      addresses: _parseAddresses(data),
      role: UserRole.customer,
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      totalSavings: (data['totalSavings'] ?? 0).toDouble(),
      avatarUrl: data['avatarUrl'],
      hasSeenSplash: data['hasSeenSplash'] ?? false,
      isProfileComplete: data['isProfileComplete'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

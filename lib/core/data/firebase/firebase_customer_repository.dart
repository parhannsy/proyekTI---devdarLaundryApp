import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';
import '../../repositories/customer_repository.dart';

/// Implementasi [CustomerRepository] menggunakan Cloud Firestore.
class FirebaseCustomerRepository implements CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<UserModel>> getAllCustomers() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .get();

    final customers =
        snapshot.docs.map((doc) => _userFromDoc(doc)).toList();
    // Sortir di Dart untuk menghindari kebutuhan composite index Firestore
    customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return customers;
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

  UserModel _userFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      nickname: data['nickname'],
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'],
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

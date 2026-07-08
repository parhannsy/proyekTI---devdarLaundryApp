import '../models/models.dart';
import '../repositories/customer_repository.dart';

class MockCustomerRepository implements CustomerRepository {
  final List<UserModel> _customers = [
    UserModel(
      id: 'cust-001',
      name: 'Ahmad Farhan',
      email: 'customer@devdara.com',
      phone: '081234567890',
      role: UserRole.customer,
      loyaltyPoints: 320,
      totalSavings: 125000,
      createdAt: DateTime(2024, 1, 15),
    ),
    UserModel(
      id: 'cust-002',
      name: 'Siti Rahayu',
      email: 'siti.rahayu@gmail.com',
      phone: '082198765432',
      role: UserRole.customer,
      loyaltyPoints: 150,
      totalSavings: 65000,
      createdAt: DateTime(2024, 3, 10),
    ),
    UserModel(
      id: 'cust-003',
      name: 'Budi Santoso',
      email: 'budi.s@yahoo.com',
      phone: '085311223344',
      role: UserRole.customer,
      loyaltyPoints: 75,
      totalSavings: 30000,
      createdAt: DateTime(2024, 5, 22),
    ),
    UserModel(
      id: 'cust-004',
      name: 'Dewi Kusuma',
      email: 'dewi.kusuma@email.com',
      phone: '087845678901',
      role: UserRole.customer,
      loyaltyPoints: 210,
      totalSavings: 87500,
      createdAt: DateTime(2024, 2, 8),
    ),
    UserModel(
      id: 'cust-005',
      name: 'Reza Pratama',
      email: 'reza.p@gmail.com',
      phone: '081567890123',
      role: UserRole.customer,
      loyaltyPoints: 45,
      totalSavings: 15000,
      createdAt: DateTime(2024, 6, 30),
    ),
  ];

  @override
  Future<List<UserModel>> getAllCustomers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_customers);
  }

  @override
  Future<UserModel?> getCustomerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel> updateCustomer(UserModel customer) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index == -1) throw Exception('Customer tidak ditemukan.');
    _customers[index] = customer;
    return customer;
  }

  @override
  Future<void> deactivateCustomer(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Dalam implementasi nyata: set isActive = false
    _customers.removeWhere((c) => c.id == id);
  }
}

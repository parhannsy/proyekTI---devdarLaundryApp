import '../models/models.dart';
import '../repositories/auth_repository.dart';

/// Implementasi mock untuk development/demo. Tidak butuh backend.
class MockAuthRepository implements AuthRepository {
  static final _users = <String, UserModel>{
    'customer@devdara.com': UserModel(
      id: 'cust-001',
      name: 'Ahmad Farhan',
      email: 'customer@devdara.com',
      phone: '081234567890',
      role: UserRole.customer,
      loyaltyPoints: 320,
      totalSavings: 125000,
      createdAt: DateTime(2024, 1, 15),
    ),
    'admin@devdara.com': UserModel(
      id: 'admin-001',
      name: 'Admin Devdara',
      email: 'admin@devdara.com',
      phone: '089876543210',
      role: UserRole.admin,
      createdAt: DateTime(2023, 6, 1),
    ),
  };

  static const _passwords = <String, String>{
    'customer@devdara.com': 'customer123',
    'admin@devdara.com': 'admin123',
  };

  UserModel? _currentUser;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final user = _users[email.toLowerCase()];
    final expectedPassword = _passwords[email.toLowerCase()];

    if (user == null || expectedPassword != password) {
      throw Exception('Email atau password salah.');
    }

    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }
}

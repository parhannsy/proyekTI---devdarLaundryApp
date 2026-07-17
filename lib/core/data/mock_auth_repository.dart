import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/auth_repository.dart';

/// Implementasi mock untuk development/demo. Tidak butuh backend.
class MockAuthRepository implements AuthRepository {
  static final _users = <String, UserModel>{
    'customer@devdara.com': UserModel(
      id: 'cust-001',
      name: 'Ahmad Farhan',
      nickname: 'Ahmad',
      email: 'customer@devdara.com',
      phone: '081234567890',
      address: 'Jl. Merdeka No. 123, Jakarta',
      role: UserRole.customer,
      loyaltyPoints: 320,
      totalSavings: 125000,
      hasSeenSplash: true,
      isProfileComplete: true,
      createdAt: DateTime(2024, 1, 15),
    ),
    'admin@devdara.com': UserModel(
      id: 'admin-001',
      name: 'Admin Devdara',
      nickname: 'Admin',
      email: 'admin@devdara.com',
      phone: '089876543210',
      address: 'Jl. Sudirman No. 45, Jakarta',
      role: UserRole.admin,
      hasSeenSplash: true,
      isProfileComplete: true,
      createdAt: DateTime(2023, 6, 1),
    ),
  };

  static const _passwords = <String, String>{
    'customer@devdara.com': 'customer123',
    'admin@devdara.com': 'admin123',
  };

  final List<UserModel> _registeredUsers = [];
  UserModel? _currentUser;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Cek di predefined users
    final user = _users[email.toLowerCase()];
    final expectedPassword = _passwords[email.toLowerCase()];

    if (user != null && expectedPassword == password) {
      _currentUser = user;
      return user;
    }

    // Cek di registered users
    try {
      final registered = _registeredUsers.firstWhere((u) => u.email == email);
      // Mock: password sudah benar karena disimpan waktu register
      _currentUser = registered;
      return registered;
    } catch (_) {
      throw Exception('Email atau password salah.');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (_users.containsKey(email) ||
        _registeredUsers.any((u) => u.email == email)) {
      throw Exception('Email sudah terdaftar.');
    }

    final newUser = UserModel(
      id: 'cust-${DateTime.now().millisecondsSinceEpoch}',
      name: '',
      nickname: '',
      email: email,
      phone: '',
      address: '',
      role: UserRole.customer,
      createdAt: DateTime.now(),
      isProfileComplete: false,
    );

    _registeredUsers.add(newUser);
    return newUser;
  }

  @override
  Future<UserModel> completeProfile({
    required String uid,
    required String name,
    required String nickname,
    required String phone,
    required String address,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Cari di predefined users
    for (final entry in _users.entries) {
      if (entry.value.id == uid) {
        final updated = entry.value.copyWith(
          name: name,
          nickname: nickname,
          phone: phone,
          address: address,
          isProfileComplete: true,
        );
        _users[entry.key] = updated;
        _currentUser = updated;
        return updated;
      }
    }

    // Cari di registered users
    final index = _registeredUsers.indexWhere((u) => u.id == uid);
    if (index != -1) {
      final updated = _registeredUsers[index].copyWith(
        name: name,
        nickname: nickname,
        phone: phone,
        address: address,
        isProfileComplete: true,
      );
      _registeredUsers[index] = updated;
      _currentUser = updated;
      return updated;
    }

    throw Exception('User tidak ditemukan.');
  }

  @override
  Future<void> markSplashSeen(String uid) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final entry in _users.entries) {
      if (entry.value.id == uid) {
        _users[entry.key] = entry.value.copyWith(hasSeenSplash: true);
        if (_currentUser?.id == uid) _currentUser = _users[entry.key];
        return;
      }
    }
    final idx = _registeredUsers.indexWhere((u) => u.id == uid);
    if (idx != -1) {
      _registeredUsers[idx] = _registeredUsers[idx].copyWith(hasSeenSplash: true);
      if (_currentUser?.id == uid) _currentUser = _registeredUsers[idx];
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String uid,
    String? name,
    String? nickname,
    String? phone,
    String? address,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Cari di predefined users
    for (final entry in _users.entries) {
      if (entry.value.id == uid) {
        var updated = entry.value;
        if (name != null) updated = updated.copyWith(name: name);
        if (nickname != null) updated = updated.copyWith(nickname: nickname);
        if (phone != null) updated = updated.copyWith(phone: phone);
        if (address != null) updated = updated.copyWith(address: address);
        _users[entry.key] = updated;
        _currentUser = updated;
        return updated;
      }
    }

    // Cari di registered users
    final idx = _registeredUsers.indexWhere((u) => u.id == uid);
    if (idx != -1) {
      var updated = _registeredUsers[idx];
      if (name != null) updated = updated.copyWith(name: name);
      if (nickname != null) updated = updated.copyWith(nickname: nickname);
      if (phone != null) updated = updated.copyWith(phone: phone);
      if (address != null) updated = updated.copyWith(address: address);
      _registeredUsers[idx] = updated;
      _currentUser = updated;
      return updated;
    }

    throw Exception('User tidak ditemukan.');
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Validasi current password
    if (_currentUser == null) {
      throw Exception('User tidak ditemukan.');
    }

    final email = _currentUser!.email;
    final expectedPassword = _passwords[email];
    if (expectedPassword != null && expectedPassword != currentPassword) {
      throw Exception('Password lama salah.');
    }

    debugPrint('[MockAuthRepo] Password berhasil diubah untuk $email');
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

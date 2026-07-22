import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthProvider(this._repository);

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isCustomer => _currentUser?.role == UserRole.customer;

  /// Apakah user perlu melengkapi profil?
  bool get needsProfileCompletion =>
      _status == AuthStatus.authenticated &&
      _currentUser?.role == UserRole.customer &&
      _currentUser?.isProfileComplete == false;

  Future<void> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.login(email: email, password: password);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  /// Registrasi akun baru (khusus admin).
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    final user = await _repository.register(
      email: email,
      password: password,
    );
    return user;
  }

  /// Lengkapi profil user baru.
  Future<UserModel> completeProfile({
    required String name,
    required String nickname,
    required String phone,
    required String address,
  }) async {
    if (_currentUser == null) throw Exception('User tidak ditemukan.');

    final updated = await _repository.completeProfile(
      uid: _currentUser!.id,
      name: name,
      nickname: nickname,
      phone: phone,
      address: address,
    );

    _currentUser = updated;
    notifyListeners();
    return updated;
  }

  /// Update profil user yang sedang login.
  Future<UserModel> updateProfile({
    String? name,
    String? nickname,
    String? phone,
    String? address,
    List<AddressModel>? addresses,
  }) async {
    if (_currentUser == null) throw Exception('User tidak ditemukan.');

    final updated = await _repository.updateProfile(
      uid: _currentUser!.id,
      name: name,
      nickname: nickname,
      phone: phone,
      address: address,
      addresses: addresses,
    );

    _currentUser = updated;
    notifyListeners();
    return updated;
  }

  /// Ganti password user yang sedang login.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) throw Exception('User tidak ditemukan.');
    await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Tandai bahwa user sudah melihat welcome splash.
  /// Update ke Firestore agar persistent.
  Future<void> markSplashSeen() async {
    if (_currentUser == null) return;
    try {
      await _repository.markSplashSeen(_currentUser!.id);
    } catch (_) {
      // Non-critical: user tetap bisa lanjut meskipun update gagal
    }
    _currentUser = _currentUser!.copyWith(hasSeenSplash: true);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

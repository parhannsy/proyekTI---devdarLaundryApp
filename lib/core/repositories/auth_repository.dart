import '../models/models.dart';

/// Kontrak interface untuk autentikasi.
/// Implementasi konkret bisa berupa mock, local, atau remote (Firebase, REST API).
abstract class AuthRepository {
  /// Login dengan email dan password.
  /// Mengembalikan [UserModel] jika berhasil, melempar Exception jika gagal.
  Future<UserModel> login({required String email, required String password});

  /// Logout pengguna yang sedang aktif.
  Future<void> logout();

  /// Mendapatkan sesi pengguna yang aktif (jika ada).
  Future<UserModel?> getCurrentUser();
}

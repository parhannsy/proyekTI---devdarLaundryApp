import '../models/models.dart';

/// Kontrak interface untuk autentikasi.
/// Implementasi konkret bisa berupa mock, local, atau remote (Firebase, REST API).
abstract class AuthRepository {
  /// Login dengan email dan password.
  /// Mengembalikan [UserModel] jika berhasil, melempar Exception jika gagal.
  Future<UserModel> login({required String email, required String password});

  /// Registrasi akun baru (khusus admin).
  /// Membuat akun di Firebase Auth + Firestore dengan role customer.
  /// Mengembalikan UserModel yang baru dibuat.
  Future<UserModel> register({
    required String email,
    required String password,
  });

  /// Menyelesaikan profil user baru (nama, nickname, phone, address).
  /// Dipanggil setelah user pertama kali login.
  Future<UserModel> completeProfile({
    required String uid,
    required String name,
    required String nickname,
    required String phone,
    required String address, // alamat pertama
  });

  /// Tandai bahwa user sudah melihat welcome splash.
  /// Update field hasSeenSplash = true di Firestore.
  Future<void> markSplashSeen(String uid);

  /// Update profil user (nama, nickname, phone, address).
  Future<UserModel> updateProfile({
    required String uid,
    String? name,
    String? nickname,
    String? phone,
    String? address, // update alamat default
    List<AddressModel>? addresses, // replace semua alamat
  });

  /// Ganti password user yang sedang login (re-authenticate + update).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Logout pengguna yang sedang aktif.
  Future<void> logout();

  /// Mendapatkan sesi pengguna yang aktif (jika ada).
  Future<UserModel?> getCurrentUser();
}

/// Extension untuk mendeteksi akun demo.
extension DemoAccount on String {
  bool get isDemoAccount =>
      this == 'customer@devdara.com' || this == 'admin@devdara.com';
}

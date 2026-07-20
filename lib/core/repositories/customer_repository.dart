import 'dart:async';
import '../models/models.dart';

/// Hasil satu halaman dari query customer paginated.
///
/// [cursor] bersifat opaque — implementasi Firebase menyimpan [DocumentSnapshot],
/// implementasi Mock menyimpan int offset. [cursor] = null berarti halaman terakhir.
class CustomerPageResult {
  final List<UserModel> customers;
  final bool hasMore;
  final Object? cursor;

  const CustomerPageResult({
    required this.customers,
    required this.hasMore,
    this.cursor,
  });
}

abstract class CustomerRepository {
  /// Mengambil semua customer (untuk admin).
  Future<List<UserModel>> getAllCustomers();

  /// Mengambil satu halaman customer (lazy load, [limit] per page).
  ///
  /// [cursor] berasal dari [CustomerPageResult.cursor] halaman sebelumnya.
  /// Kirim null untuk halaman pertama.
  Future<CustomerPageResult> getCustomersPage({
    required int limit,
    Object? cursor,
  });

  /// Stream realtime semua customer (admin).
  /// Setiap ada perubahan di Firestore, data otomatis dikirim.
  Stream<List<UserModel>> streamCustomers();

  /// Mengambil detail satu customer.
  Future<UserModel?> getCustomerById(String id);

  /// Memperbarui data profil customer.
  Future<UserModel> updateCustomer(UserModel customer);

  /// Menonaktifkan akun customer.
  Future<void> deactivateCustomer(String id);
}

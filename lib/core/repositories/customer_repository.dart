import '../models/models.dart';

abstract class CustomerRepository {
  /// Mengambil semua customer (untuk admin).
  Future<List<UserModel>> getAllCustomers();

  /// Mengambil detail satu customer.
  Future<UserModel?> getCustomerById(String id);

  /// Memperbarui data profil customer.
  Future<UserModel> updateCustomer(UserModel customer);

  /// Menonaktifkan akun customer.
  Future<void> deactivateCustomer(String id);
}

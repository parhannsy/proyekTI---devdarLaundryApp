import '../models/models.dart';

abstract class VoucherRepository {
  /// Mengambil semua voucher (untuk admin).
  Future<List<VoucherModel>> getAllVouchers();

  /// Mengambil voucher yang aktif dan publik (untuk customer).
  Future<List<VoucherModel>> getActivePublicVouchers();

  /// Membuat voucher baru.
  Future<VoucherModel> createVoucher(VoucherModel voucher);

  /// Memperbarui data voucher.
  Future<VoucherModel> updateVoucher(VoucherModel voucher);

  /// Menghapus voucher.
  Future<void> deleteVoucher(String id);

  /// Memvalidasi kode voucher dan mengembalikan voucher jika valid.
  Future<VoucherModel?> validateCode(String code);

  /// Menandai voucher sebagai digunakan oleh customer.
  Future<void> redeemVoucher(String voucherId, String customerId);
}

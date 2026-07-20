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

  /// Menandai voucher sebagai digunakan oleh customer (increment quota).
  Future<void> redeemVoucher(String voucherId, String customerId);

  /// Mencatat klaim voucher oleh customer di collection terpisah.
  Future<void> claimVoucher(String voucherId, String customerId);

  /// Mengambil daftar ID voucher yang sudah diklaim oleh customer.
  Future<List<String>> getClaimedVoucherIds(String customerId);

  /// Mengambil daftar ID customer yang sudah mengklaim voucher tertentu.
  Future<List<String>> getClaimantsByVoucher(String voucherId);

  /// Increment claimCount pada voucher (batas siapa cepat dia dapat).
  Future<void> incrementClaimCount(String voucherId);
}

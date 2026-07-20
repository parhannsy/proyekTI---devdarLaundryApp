import '../models/models.dart';
import '../repositories/voucher_repository.dart';

class MockVoucherRepository implements VoucherRepository {
  final List<VoucherModel> _vouchers = [
    VoucherModel(
      id: 'v-001',
      code: 'WELCOME20',
      title: 'Diskon 20% Order Pertama',
      description: 'Khusus untuk pelanggan baru Devdara Laundry',
      type: VoucherType.percentage,
      value: 20,
      minimumOrder: 30000,
      totalQuota: 100,
      usedQuota: 43,
      validFrom: DateTime(2024, 1, 1),
      validUntil: DateTime(2025, 12, 31),
    ),
    VoucherModel(
      id: 'v-002',
      code: 'ONGKIRFREE',
      title: 'Gratis Ongkir s/d 5km',
      description: 'Berlaku untuk semua jenis layanan. Gratis ongkos antar jemput.',
      type: VoucherType.freeShipping,
      value: 15000,
      totalQuota: 200,
      usedQuota: 87,
      validFrom: DateTime(2024, 6, 1),
      validUntil: DateTime(2025, 8, 31),
    ),
    VoucherModel(
      id: 'v-003',
      code: 'SEPATU10K',
      title: 'Gratis Cuci Sepatu',
      description: 'Gratis cuci 1 pasang sepatu dengan minimum order 5kg',
      type: VoucherType.fixed,
      value: 25000,
      minimumOrder: 50000,
      totalQuota: 50,
      usedQuota: 50,
      validFrom: DateTime(2024, 3, 1),
      validUntil: DateTime(2024, 5, 31),
      status: VoucherStatus.expired,
    ),
    VoucherModel(
      id: 'v-004',
      code: 'LOYAL15',
      title: 'Diskon Loyalitas 15%',
      description: 'Hadiah untuk pelanggan setia yang sudah order 10x',
      type: VoucherType.percentage,
      value: 15,
      totalQuota: 30,
      usedQuota: 12,
      validFrom: DateTime(2024, 7, 1),
      validUntil: DateTime(2025, 7, 31),
      isPublic: false,
    ),
  ];

  @override
  Future<List<VoucherModel>> getAllVouchers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_vouchers);
  }

  @override
  Future<List<VoucherModel>> getActivePublicVouchers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _vouchers
        .where((v) => v.isAvailable && v.isPublic)
        .toList();
  }

  @override
  Future<VoucherModel> createVoucher(VoucherModel voucher) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _vouchers.add(voucher);
    return voucher;
  }

  @override
  Future<VoucherModel> updateVoucher(VoucherModel voucher) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _vouchers.indexWhere((v) => v.id == voucher.id);
    if (index == -1) throw Exception('Voucher tidak ditemukan.');
    _vouchers[index] = voucher;
    return voucher;
  }

  @override
  Future<void> deleteVoucher(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Hapus semua claim records untuk voucher ini
    _claimedRecords.removeWhere((r) => r.voucherId == id);
    // Hapus dokumen voucher
    _vouchers.removeWhere((v) => v.id == id);
  }

  @override
  Future<VoucherModel?> validateCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _vouchers.firstWhere(
        (v) => v.code.toUpperCase() == code.toUpperCase() && v.isAvailable,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> redeemVoucher(String voucherId, String customerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _vouchers.indexWhere((v) => v.id == voucherId);
    if (index != -1) {
      _vouchers[index] = _vouchers[index].copyWith(
        usedQuota: _vouchers[index].usedQuota + 1,
      );
    }
  }

  // ── Claimed vouchers (in-memory store) ─────────────────────
  final List<_ClaimRecord> _claimedRecords = [];

  @override
  Future<void> incrementClaimCount(String voucherId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _vouchers.indexWhere((v) => v.id == voucherId);
    if (index != -1) {
      _vouchers[index] = _vouchers[index].copyWith(
        claimCount: _vouchers[index].claimCount + 1,
      );
    }
  }

  @override
  Future<void> claimVoucher(String voucherId, String customerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _claimedRecords.add(_ClaimRecord(
      id: '${customerId}_$voucherId',
      customerId: customerId,
      voucherId: voucherId,
    ));
  }

  @override
  Future<List<String>> getClaimantsByVoucher(String voucherId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _claimedRecords
        .where((r) => r.voucherId == voucherId)
        .map((r) => r.customerId)
        .toList();
  }

  @override
  Future<List<String>> getClaimedVoucherIds(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _claimedRecords
        .where((r) => r.customerId == customerId)
        .map((r) => r.voucherId)
        .toList();
  }
}

class _ClaimRecord {
  final String id;
  final String customerId;
  final String voucherId;
  const _ClaimRecord({
    required this.id,
    required this.customerId,
    required this.voucherId,
  });
}

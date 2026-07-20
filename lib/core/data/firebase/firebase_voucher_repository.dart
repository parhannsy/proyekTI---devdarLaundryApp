import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';
import '../../repositories/voucher_repository.dart';

/// Implementasi [VoucherRepository] menggunakan Cloud Firestore.
class FirebaseVoucherRepository implements VoucherRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _vouchers => _firestore.collection('vouchers');

  @override
  Future<List<VoucherModel>> getAllVouchers() async {
    final snapshot = await _vouchers
        .orderBy('validUntil', descending: true)
        .get();

    return snapshot.docs.map((doc) => _voucherFromDoc(doc)).toList();
  }

  @override
  Future<List<VoucherModel>> getActivePublicVouchers() async {
    final now = DateTime.now();
    final snapshot = await _vouchers
        .where('isPublic', isEqualTo: true)
        .get();

    final vouchers = snapshot.docs
        .map((doc) => _voucherFromDoc(doc))
        .where((v) => v.isAvailable && v.validUntil.isAfter(now))
        .toList();
    // Sortir di Dart untuk menghindari kebutuhan composite index Firestore
    vouchers.sort((a, b) => a.validUntil.compareTo(b.validUntil));
    return vouchers;
  }

  @override
  Future<VoucherModel> createVoucher(VoucherModel voucher) async {
    final docRef = _vouchers.doc();
    await docRef.set(_voucherToDoc(voucher.copyWith(
      id: docRef.id,
      status: VoucherStatus.active,
    )));
    return voucher.copyWith(id: docRef.id);
  }

  @override
  Future<VoucherModel> updateVoucher(VoucherModel voucher) async {
    await _vouchers.doc(voucher.id).update(_voucherToDoc(voucher));
    return voucher;
  }

  @override
  Future<void> deleteVoucher(String id) async {
    // Cari semua user yang memiliki voucher ini di claimedVouchers
    final snapshot = await _firestore
        .collection('users')
        .where('claimedVouchers', arrayContains: id)
        .get();

    // Hapus voucherId dari array claimedVouchers setiap user
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'claimedVouchers': FieldValue.arrayRemove([id]),
      });
    }
    // Hapus dokumen voucher
    batch.delete(_vouchers.doc(id));

    // Eksekusi semua operasi dalam satu batch
    await batch.commit();
  }

  @override
  Future<VoucherModel?> validateCode(String code) async {
    final snapshot = await _vouchers
        .where('code', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final voucher = _voucherFromDoc(snapshot.docs.first);
    return voucher.isAvailable ? voucher : null;
  }

  @override
  Future<void> redeemVoucher(String voucherId, String customerId) async {
    await _vouchers.doc(voucherId).update({
      'usedQuota': FieldValue.increment(1),
    });
  }

  @override
  Future<void> incrementClaimCount(String voucherId) async {
    await _vouchers.doc(voucherId).update({
      'claimCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> claimVoucher(String voucherId, String customerId) async {
    // Simpan di array claimedVouchers pada dokumen user
    // (akses diatur oleh rules users/{userId} yang sudah ada)
    await _firestore.collection('users').doc(customerId).update({
      'claimedVouchers': FieldValue.arrayUnion([voucherId]),
    });
  }

  @override
  Future<List<String>> getClaimantsByVoucher(String voucherId) async {
    final snapshot = await _firestore
        .collection('users')
        .where('claimedVouchers', arrayContains: voucherId)
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  @override
  Future<List<String>> getClaimedVoucherIds(String customerId) async {
    final doc = await _firestore.collection('users').doc(customerId).get();
    if (!doc.exists) return [];
    final data = doc.data() as Map<String, dynamic>;
    final list = data['claimedVouchers'];
    if (list is List) return list.cast<String>();
    return [];
  }

  VoucherModel _voucherFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VoucherModel(
      id: doc.id,
      code: data['code'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: _parseVoucherType(data['type']),
      value: (data['value'] ?? 0).toDouble(),
      minimumOrder: (data['minimumOrder'] as num?)?.toDouble(),
      totalQuota: data['totalQuota'] ?? 0,
      usedQuota: data['usedQuota'] ?? 0,
      claimCount: data['claimCount'] ?? 0,
      claimLimit: (data['claimLimit'] as int?),
      validFrom: (data['validFrom'] as Timestamp).toDate(),
      validUntil: (data['validUntil'] as Timestamp).toDate(),
      status: _parseVoucherStatus(data['status']),
      isPublic: data['isPublic'] ?? true,
    );
  }

  Map<String, dynamic> _voucherToDoc(VoucherModel voucher) {
    return {
      'code': voucher.code,
      'title': voucher.title,
      'description': voucher.description,
      'type': voucher.type.name,
      'value': voucher.value,
      'minimumOrder': voucher.minimumOrder,
      'totalQuota': voucher.totalQuota,
      'usedQuota': voucher.usedQuota,
      'claimCount': voucher.claimCount,
      'claimLimit': voucher.claimLimit,
      'validFrom': voucher.validFrom,
      'validUntil': voucher.validUntil,
      'status': voucher.status.name,
      'isPublic': voucher.isPublic,
    };
  }

  VoucherType _parseVoucherType(String? value) {
    return VoucherType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VoucherType.percentage,
    );
  }

  VoucherStatus _parseVoucherStatus(String? value) {
    return VoucherStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VoucherStatus.active,
    );
  }
}

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
    await _vouchers.doc(id).delete();
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

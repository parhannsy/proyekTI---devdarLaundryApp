import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/voucher_repository.dart';

class VoucherProvider extends ChangeNotifier {
  final VoucherRepository _repository;

  List<VoucherModel> _vouchers = [];
  bool _isLoading = false;
  String? _errorMessage;

  VoucherProvider(this._repository);

  List<VoucherModel> get vouchers => _vouchers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<VoucherModel> get activeVouchers =>
      _vouchers.where((v) => v.isAvailable).toList();

  Future<void> loadAllVouchers() async {
    _setLoading(true);
    try {
      _vouchers = await _repository.getAllVouchers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPublicVouchers() async {
    _setLoading(true);
    try {
      _vouchers = await _repository.getActivePublicVouchers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createVoucher(VoucherModel voucher) async {
    try {
      final created = await _repository.createVoucher(voucher);
      _vouchers.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVoucher(VoucherModel voucher) async {
    try {
      final updated = await _repository.updateVoucher(voucher);
      final index = _vouchers.indexWhere((v) => v.id == voucher.id);
      if (index != -1) {
        _vouchers[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteVoucher(String id) async {
    try {
      await _repository.deleteVoucher(id);
      _vouchers.removeWhere((v) => v.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Menandai voucher sebagai digunakan oleh customer (increment usedQuota).
  Future<bool> redeemVoucher(String voucherId, String customerId) async {
    try {
      await _repository.redeemVoucher(voucherId, customerId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Mencatat klaim voucher oleh customer di collection terpisah.
  Future<bool> claimVoucher(String voucherId, String customerId) async {
    try {
      await _repository.claimVoucher(voucherId, customerId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Increment claimCount pada voucher.
  Future<bool> incrementClaimCount(String voucherId) async {
    try {
      await _repository.incrementClaimCount(voucherId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Mengambil daftar ID voucher yang sudah diklaim oleh customer.
  Future<List<String>> getClaimedVoucherIds(String customerId) async {
    try {
      return await _repository.getClaimedVoucherIds(customerId);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

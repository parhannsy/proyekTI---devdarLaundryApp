import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/customer_repository.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _repository;

  static const int pageSize = 10;

  List<UserModel> _customers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Object? _cursor;
  String? _errorMessage;

  // Stream subscription untuk realtime update
  StreamSubscription<List<UserModel>>? _streamSub;

  CustomerProvider(this._repository);

  List<UserModel> get customers => _customers;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  int get totalCustomers => _customers.length;

  // ── Stream (Admin - realtime) ─────────────────────────────

  /// Mulai mendengarkan stream realtime dari Firestore.
  /// Setiap ada perubahan data, _customers otomatis update
  /// dan Consumer di UI akan rebuild.
  ///
  /// Stream mengirim full list, jadi pagination dinonaktifkan
  /// dengan set _hasMore = false agar scroll listener tidak
  /// memicu loadMoreCustomers() yang tidak berguna.
  void listenCustomers() {
    _streamSub?.cancel();

    _hasMore = false;
    _cursor = null;
    _isLoading = true;
    notifyListeners();

    _streamSub = _repository.streamCustomers().listen(
      (updatedCustomers) {
        _customers = updatedCustomers;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
        debugPrint('[CustomerProvider] Stream error: $error');
      },
    );
  }

  /// Hentikan stream — panggil saat widget di-dispose.
  void stopListening() {
    _streamSub?.cancel();
    _streamSub = null;
  }

  // ── One-time fetch (fallback) ─────────────────────────────

  Future<void> loadCustomers() async {
    _errorMessage = null;
    _hasMore = true;
    _cursor = null;
    _setLoading(true);
    try {
      final result = await _repository.getCustomersPage(
        limit: pageSize,
        cursor: null,
      );
      _customers = result.customers;
      _customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _hasMore = result.hasMore;
      _cursor = result.cursor;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreCustomers() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getCustomersPage(
        limit: pageSize,
        cursor: _cursor,
      );
      _customers.addAll(result.customers);
      _customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _hasMore = result.hasMore;
      _cursor = result.cursor;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Single record ops ──────────────────────────────────────

  Future<bool> updateCustomer(UserModel customer) async {
    try {
      final updated = await _repository.updateCustomer(customer);
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deactivateCustomer(String id) async {
    try {
      await _repository.deactivateCustomer(id);
      _customers.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}


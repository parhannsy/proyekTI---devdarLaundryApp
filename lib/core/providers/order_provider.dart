import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;

  List<OrderModel> _orders = [];
  List<OrderModel> _activeOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<OrderModel>>? _streamSub;

  OrderProvider(this._repository);

  List<OrderModel> get orders => _orders;
  List<OrderModel> get activeOrders => _activeOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Stream (Admin - realtime) ─────────────────────────────

  /// Mulai mendengarkan stream realtime dari Firestore.
  /// Setiap ada perubahan data, `_orders` akan otomatis update
  /// dan Consumer di UI akan rebuild.
  void listenAllOrders() {
    // Cancel subscription sebelumnya jika ada (mencegah duplikasi)
    _streamSub?.cancel();

    _isLoading = true;
    notifyListeners();

    _streamSub = _repository.streamAllOrders().listen(
      (updatedOrders) {
        _orders = updatedOrders;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
        debugPrint('[OrderProvider] Stream error: $error');
      },
    );
  }

  /// Hentikan stream — panggil saat widget di-dispose.
  void stopListening() {
    _streamSub?.cancel();
    _streamSub = null;
  }

  // ── Admin ──────────────────────────────────────────────────

  Future<void> loadAllOrders() async {
    _setLoading(true);
    try {
      _orders = await _repository.getAllOrders();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Admin menerima permohonan & memberikan estimasi biaya.
  Future<void> acceptRequest(String orderId, {required double estimatedTotal}) async {
    try {
      final updated = await _repository.acceptOrder(orderId, estimatedTotal: estimatedTotal);
      _replaceInList(updated);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Admin menolak permohonan dengan alasan.
  Future<void> rejectRequest(String orderId, {required String reason}) async {
    try {
      final updated = await _repository.rejectOrder(orderId, reason: reason);
      _replaceInList(updated);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Admin mengupdate status order ke tahap berikutnya.
  Future<void> updateStatus(String orderId, OrderStatus status) async {
    try {
      final updated = await _repository.updateOrderStatus(orderId, status);
      _replaceInList(updated);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _repository.deleteOrder(orderId);
      _orders.removeWhere((o) => o.id == orderId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Customer ───────────────────────────────────────────────

  Future<void> loadActiveOrders(String customerId) async {
    _setLoading(true);
    try {
      _activeOrders = await _repository.getActiveOrdersByCustomer(customerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCustomerOrders(String customerId) async {
    _setLoading(true);
    try {
      _orders = await _repository.getOrdersByCustomer(customerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Customer menyetujui estimasi biaya + memilih voucher → status berubah ke pickedUp.
  /// [discount] dan [voucherCode] dari voucher yang dipilih customer.
  /// Return true jika berhasil, false jika gagal.
  Future<bool> agreeToOrder(String orderId, {double discount = 0, String? voucherCode}) async {
    try {
      final updated = await _repository.updateOrderStatus(orderId, OrderStatus.pickedUp, discount: discount, voucherCode: voucherCode);
      _replaceInList(updated);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Customer membatalkan order.
  /// Return true jika berhasil, false jika gagal.
  Future<bool> cancelOrder(String orderId) async {
    try {
      final updated = await _repository.updateOrderStatus(orderId, OrderStatus.cancelled);
      _replaceInList(updated);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Membuat order baru (dari customer).
  Future<OrderModel?> createOrder(OrderModel order) async {
    try {
      final created = await _repository.createOrder(order);
      _orders.insert(0, created);
      notifyListeners();
      return created;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ── Summary helpers ────────────────────────────────────────

  int get pendingCount =>
      _orders.where((o) => o.status == OrderStatus.request).length;

  int get processingCount =>
      _orders.where((o) => o.status == OrderStatus.processing).length;

  int get deliveringCount =>
      _orders.where((o) => o.status == OrderStatus.delivering).length;

  int get readyCount =>
      _orders.where((o) => o.status == OrderStatus.accepted).length;

  double get todayRevenue {
    final today = DateTime.now();
    return _orders
        .where((o) =>
            o.completedAt != null &&
            o.completedAt!.year == today.year &&
            o.completedAt!.month == today.month &&
            o.completedAt!.day == today.day)
        .fold(0.0, (sum, o) => sum + o.finalPrice);
  }

  // ── Internal helpers ───────────────────────────────────────

  void _replaceInList(OrderModel updated) {
    final index = _orders.indexWhere((o) => o.id == updated.id);
    if (index != -1) {
      _orders[index] = updated;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

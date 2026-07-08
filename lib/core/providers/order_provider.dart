import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;

  List<OrderModel> _orders = [];
  List<OrderModel> _activeOrders = [];
  bool _isLoading = false;
  String? _errorMessage;

  OrderProvider(this._repository);

  List<OrderModel> get orders => _orders;
  List<OrderModel> get activeOrders => _activeOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    try {
      final updated = await _repository.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updated;
        notifyListeners();
      }
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

  // ── Summary helpers ────────────────────────────────────────

  int get pendingCount =>
      _orders.where((o) => o.status == OrderStatus.pending).length;

  int get processingCount => _orders
      .where((o) =>
          o.status == OrderStatus.received ||
          o.status == OrderStatus.washing ||
          o.status == OrderStatus.drying ||
          o.status == OrderStatus.ironing)
      .length;

  int get readyCount =>
      _orders.where((o) => o.status == OrderStatus.ready).length;

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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

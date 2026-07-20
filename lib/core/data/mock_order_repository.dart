import 'dart:async';
import '../models/models.dart';
import '../repositories/order_repository.dart';
import 'mock_data_store.dart';

class MockOrderRepository implements OrderRepository {
  List<OrderModel> get _orders => MockDataStore.orders;

  @override
  Future<List<OrderModel>> getAllOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_orders);
  }

  @override
  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((o) => o.customerId == customerId).toList();
  }

  @override
  Future<List<OrderModel>> getActiveOrdersByCustomer(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders
        .where((o) =>
            o.customerId == customerId && o.status.isActive)
        .toList();
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<OrderModel> updateOrderStatus(String id, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) throw Exception('Order tidak ditemukan.');

    final current = _orders[index];
    double totalPrice = current.totalPrice;
    if (status == OrderStatus.completed && totalPrice == 0 && current.estimatedTotal != null) {
      totalPrice = current.estimatedTotal!;
    }

    final updated = current.copyWith(
      status: status,
      totalPrice: totalPrice,
      completedAt: status == OrderStatus.completed ? DateTime.now() : null,
    );
    _orders[index] = updated;
    return updated;
  }

  @override
  Future<OrderModel> acceptOrder(String id,
      {required double estimatedTotal}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) throw Exception('Order tidak ditemukan.');
    if (_orders[index].status != OrderStatus.request) {
      throw Exception('Status order harus Permohonan untuk bisa diterima.');
    }
    final updated = _orders[index].copyWith(
      status: OrderStatus.accepted,
      estimatedTotal: estimatedTotal,
    );
    _orders[index] = updated;
    return updated;
  }

  @override
  Future<OrderModel> rejectOrder(String id,
      {required String reason}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) throw Exception('Order tidak ditemukan.');
    final updated = _orders[index].copyWith(
      status: OrderStatus.rejected,
      rejectionReason: reason,
    );
    _orders[index] = updated;
    return updated;
  }

  @override
  Stream<List<OrderModel>> streamAllOrders() {
    final controller = StreamController<List<OrderModel>>.broadcast();

    final timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!controller.isClosed) {
        controller.add(List.from(_orders));
      }
    });

    controller.onCancel = () => timer.cancel();

    Future.microtask(() {
      if (!controller.isClosed) {
        controller.add(List.from(_orders));
      }
    });

    return controller.stream;
  }

  @override
  Future<void> deleteOrder(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _orders.removeWhere((o) => o.id == id);
  }
}

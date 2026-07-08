import '../models/models.dart';
import '../repositories/order_repository.dart';

class MockOrderRepository implements OrderRepository {
  final List<OrderModel> _orders = [
    OrderModel(
      id: 'ORD-2024-042',
      customerId: 'cust-001',
      customerName: 'Ahmad Farhan',
      category: OrderCategory.regular,
      weight: 3.5,
      quantity: 1,
      status: OrderStatus.washing,
      totalPrice: 35000,
      discount: 0,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      estimatedDoneAt: DateTime.now().add(const Duration(hours: 19)),
    ),
    OrderModel(
      id: 'ORD-2024-041',
      customerId: 'cust-001',
      customerName: 'Ahmad Farhan',
      category: OrderCategory.carpet,
      weight: 0,
      quantity: 2,
      status: OrderStatus.received,
      totalPrice: 80000,
      discount: 0,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      estimatedDoneAt: DateTime.now().add(const Duration(days: 1)),
    ),
    OrderModel(
      id: 'ORD-2024-040',
      customerId: 'cust-002',
      customerName: 'Siti Rahayu',
      category: OrderCategory.express,
      weight: 2.0,
      quantity: 1,
      status: OrderStatus.ready,
      totalPrice: 40000,
      discount: 8000,
      voucherCode: 'WELCOME20',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      estimatedDoneAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    OrderModel(
      id: 'ORD-2024-039',
      customerId: 'cust-003',
      customerName: 'Budi Santoso',
      category: OrderCategory.shoes,
      weight: 0,
      quantity: 3,
      status: OrderStatus.delivered,
      totalPrice: 75000,
      discount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    OrderModel(
      id: 'ORD-2024-038',
      customerId: 'cust-002',
      customerName: 'Siti Rahayu',
      category: OrderCategory.dryClean,
      weight: 1.5,
      quantity: 2,
      status: OrderStatus.delivered,
      totalPrice: 90000,
      discount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      completedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    OrderModel(
      id: 'ORD-2024-037',
      customerId: 'cust-004',
      customerName: 'Dewi Kusuma',
      category: OrderCategory.regular,
      weight: 4.0,
      quantity: 1,
      status: OrderStatus.ironing,
      totalPrice: 40000,
      discount: 0,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      estimatedDoneAt: DateTime.now().add(const Duration(hours: 14)),
    ),
  ];

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
            o.customerId == customerId &&
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled)
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
    final updated = _orders[index].copyWith(
      status: status,
      completedAt: status == OrderStatus.delivered ? DateTime.now() : null,
    );
    _orders[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteOrder(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _orders.removeWhere((o) => o.id == id);
  }
}

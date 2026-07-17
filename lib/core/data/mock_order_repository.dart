import 'dart:async';
import '../models/models.dart';
import '../repositories/order_repository.dart';

class MockOrderRepository implements OrderRepository {
  final List<OrderModel> _orders = [
    OrderModel(
      id: 'ORD-2026-001',
      customerId: 'cust-001',
      customerName: 'Ahmad Farhan',
      customerAddress: 'Jl. Merdeka No. 10, Jakarta',
      category: OrderCategory.regular,
      itemName: 'Baju & Celana',
      unitType: UnitType.kiloan,
      quantity: 3.5,
      status: OrderStatus.processing,
      totalPrice: 0,
      pickupDate: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    OrderModel(
      id: 'ORD-2026-002',
      customerId: 'cust-001',
      customerName: 'Ahmad Farhan',
      customerAddress: 'Jl. Merdeka No. 10, Jakarta',
      category: OrderCategory.carpet,
      itemName: 'Karpet Ruang Tamu',
      unitType: UnitType.meteran,
      quantity: 4.0,
      status: OrderStatus.accepted,
      totalPrice: 0,
      estimatedTotal: 80000,
      pickupDate: DateTime.now().add(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    OrderModel(
      id: 'ORD-2026-003',
      customerId: 'cust-002',
      customerName: 'Siti Rahayu',
      customerAddress: 'Jl. Sudirman No. 25, Jakarta',
      category: OrderCategory.express,
      itemName: 'Seragam Kerja',
      unitType: UnitType.kiloan,
      quantity: 2.0,
      status: OrderStatus.request,
      totalPrice: 0,
      pickupDate: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    OrderModel(
      id: 'ORD-2026-004',
      customerId: 'cust-003',
      customerName: 'Budi Santoso',
      customerAddress: 'Jl. Gatot Subroto No. 5, Jakarta',
      category: OrderCategory.shoes,
      itemName: 'Sepatu Olahraga',
      unitType: UnitType.satuan,
      quantity: 2,
      status: OrderStatus.completed,
      totalPrice: 50000,
      discount: 0,
      pickupDate: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    OrderModel(
      id: 'ORD-2026-005',
      customerId: 'cust-002',
      customerName: 'Siti Rahayu',
      customerAddress: 'Jl. Sudirman No. 25, Jakarta',
      category: OrderCategory.dryClean,
      itemName: 'Jas & Kebaya',
      unitType: UnitType.satuan,
      quantity: 2,
      status: OrderStatus.delivering,
      totalPrice: 90000,
      discount: 0,
      pickupDate: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    OrderModel(
      id: 'ORD-2026-006',
      customerId: 'cust-004',
      customerName: 'Dewi Kusuma',
      customerAddress: 'Jl. Thamrin No. 8, Jakarta',
      category: OrderCategory.regular,
      itemName: 'Handuk & Sprei',
      unitType: UnitType.kiloan,
      quantity: 4.0,
      status: OrderStatus.delivering,
      totalPrice: 40000,
      discount: 0,
      pickupDate: DateTime.now().subtract(const Duration(hours: 8)),
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    OrderModel(
      id: 'ORD-2026-007',
      customerId: 'cust-005',
      customerName: 'Reza Pratama',
      customerAddress: 'Jl. Kuningan No. 15, Jakarta',
      category: OrderCategory.regular,
      itemName: 'Kaos & Jeans',
      unitType: UnitType.kiloan,
      quantity: 2.5,
      status: OrderStatus.rejected,
      totalPrice: 0,
      rejectionReason: 'Lokasi diluar jangkauan pengiriman',
      pickupDate: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
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
    final updated = _orders[index].copyWith(
      status: status,
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
    // StreamController + timer periodik untuk simulasi realtime
    // Setiap 3 detik, emit data terbaru (termasuk perubahan dari createOrder dll)
    final controller = StreamController<List<OrderModel>>.broadcast();

    final timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!controller.isClosed) {
        controller.add(List.from(_orders));
      }
    });

    // Bersihin timer otomatis saat stream subscription di-cancel
    controller.onCancel = () => timer.cancel();

    // Emit data pertama segera
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

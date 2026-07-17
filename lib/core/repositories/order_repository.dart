import '../models/models.dart';

abstract class OrderRepository {
  /// Mengambil semua order (untuk admin).
  Future<List<OrderModel>> getAllOrders();

  /// Mengambil order milik satu customer.
  Future<List<OrderModel>> getOrdersByCustomer(String customerId);

  /// Mengambil order yang sedang aktif milik customer.
  Future<List<OrderModel>> getActiveOrdersByCustomer(String customerId);

  /// Mengambil detail satu order berdasarkan ID.
  Future<OrderModel?> getOrderById(String id);

  /// Membuat order baru (dari customer).
  Future<OrderModel> createOrder(OrderModel order);

  /// Memperbarui status order.
  Future<OrderModel> updateOrderStatus(String id, OrderStatus status);

  /// Admin menerima permohonan order + memberikan estimasi biaya.
  Future<OrderModel> acceptOrder(String id, {required double estimatedTotal});

  /// Admin menolak permohonan order dengan alasan.
  Future<OrderModel> rejectOrder(String id, {required String reason});

  /// Stream realtime untuk semua order (admin).
  Stream<List<OrderModel>> streamAllOrders();

  /// Menghapus order (soft delete, oleh admin).
  Future<void> deleteOrder(String id);
}

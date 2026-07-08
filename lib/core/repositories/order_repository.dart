import '../models/models.dart';

abstract class OrderRepository {
  /// Mengambil semua order (untuk admin).
  Future<List<OrderModel>> getAllOrders();

  /// Mengambil order milik satu customer.
  Future<List<OrderModel>> getOrdersByCustomer(String customerId);

  /// Mengambil order yang sedang aktif (belum selesai) milik customer.
  Future<List<OrderModel>> getActiveOrdersByCustomer(String customerId);

  /// Mengambil detail satu order berdasarkan ID.
  Future<OrderModel?> getOrderById(String id);

  /// Membuat order baru.
  Future<OrderModel> createOrder(OrderModel order);

  /// Memperbarui status order (oleh admin).
  Future<OrderModel> updateOrderStatus(String id, OrderStatus status);

  /// Menghapus order (soft delete, oleh admin).
  Future<void> deleteOrder(String id);
}

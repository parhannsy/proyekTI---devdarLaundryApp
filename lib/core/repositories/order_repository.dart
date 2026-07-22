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
  /// [discount] dan [voucherCode] diisi saat customer setuju & pilih voucher.
  Future<OrderModel> updateOrderStatus(String id, OrderStatus status, {double discount = 0, String? voucherCode});

  /// Admin menerima permohonan order + memberikan estimasi biaya.
  Future<OrderModel> acceptOrder(String id, {required double estimatedTotal});

  /// Admin menolak permohonan order dengan alasan.
  Future<OrderModel> rejectOrder(String id, {required String reason});

  /// Stream realtime untuk semua order (admin).
  Stream<List<OrderModel>> streamAllOrders();

  /// Stream realtime untuk order milik satu customer tertentu.
  Stream<List<OrderModel>> streamOrdersByCustomer(String customerId);

  /// Menghapus order (soft delete, oleh admin).
  Future<void> deleteOrder(String id);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';
import '../../repositories/order_repository.dart';

/// Implementasi [OrderRepository] menggunakan Cloud Firestore.
class FirebaseOrderRepository implements OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _orders => _firestore.collection('orders');

  @override
  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _orders
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => _orderFromDoc(doc)).toList();
  }

  @override
  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    final snapshot = await _orders
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => _orderFromDoc(doc)).toList();
  }

  @override
  Future<List<OrderModel>> getActiveOrdersByCustomer(String customerId) async {
    final snapshot = await _orders
        .where('customerId', isEqualTo: customerId)
        .where('status', whereIn: [
          OrderStatus.pending.name,
          OrderStatus.received.name,
          OrderStatus.washing.name,
          OrderStatus.drying.name,
          OrderStatus.ironing.name,
          OrderStatus.ready.name,
        ])
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => _orderFromDoc(doc)).toList();
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    final doc = await _orders.doc(id).get();
    if (!doc.exists) return null;
    return _orderFromDoc(doc);
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    final docRef = _orders.doc();
    final data = _orderToDoc(order.copyWith(id: docRef.id));
    await docRef.set(data);
    return order.copyWith(id: docRef.id);
  }

  @override
  Future<OrderModel> updateOrderStatus(String id, OrderStatus status) async {
    await _orders.doc(id).update({
      'status': status.name,
      if (status == OrderStatus.delivered) 'completedAt': DateTime.now(),
    });

    final doc = await _orders.doc(id).get();
    return _orderFromDoc(doc);
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _orders.doc(id).delete();
  }

  OrderModel _orderFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      category: _parseCategory(data['category']),
      weight: (data['weight'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      status: _parseStatus(data['status']),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      voucherCode: data['voucherCode'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      estimatedDoneAt: data['estimatedDoneAt'] != null
          ? (data['estimatedDoneAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> _orderToDoc(OrderModel order) {
    return {
      'customerId': order.customerId,
      'customerName': order.customerName,
      'category': order.category.name,
      'weight': order.weight,
      'quantity': order.quantity,
      'status': order.status.name,
      'totalPrice': order.totalPrice,
      'discount': order.discount,
      'voucherCode': order.voucherCode,
      'notes': order.notes,
      'createdAt': order.createdAt,
      'estimatedDoneAt': order.estimatedDoneAt,
      'completedAt': order.completedAt,
    };
  }

  OrderCategory _parseCategory(String? value) {
    return OrderCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderCategory.regular,
    );
  }

  OrderStatus _parseStatus(String? value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

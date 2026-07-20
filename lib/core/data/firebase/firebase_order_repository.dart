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
        .get();

    final orders =
        snapshot.docs.map((doc) => _orderFromDoc(doc)).toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<List<OrderModel>> getActiveOrdersByCustomer(String customerId) async {
    final snapshot = await _orders
        .where('customerId', isEqualTo: customerId)
        .get();

    final orders = snapshot.docs
        .map((doc) => _orderFromDoc(doc))
        .where((o) => o.status.isActive)
        .toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
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
  Future<OrderModel> updateOrderStatus(String id, OrderStatus status, {double discount = 0, String? voucherCode}) async {
    final updates = <String, dynamic>{
      'status': status.name,
    };

    // Saat customer setuju, simpan diskon + kode voucher + totalPrice
    if (status == OrderStatus.pickedUp) {
      if (discount > 0 || voucherCode != null) {
        updates['discount'] = discount;
        updates['voucherCode'] = voucherCode;
      }
      // Set totalPrice = estimatedTotal agar finalPrice langsung akurat
      final current = await _orders.doc(id).get();
      if (current.exists) {
        final data = current.data() as Map<String, dynamic>;
        if (data['estimatedTotal'] != null) {
          updates['totalPrice'] = (data['estimatedTotal'] as num).toDouble();
        }
      }
    }

    if (status == OrderStatus.completed) {
      updates['completedAt'] = DateTime.now();
    }

    await _orders.doc(id).update(updates);
    final doc = await _orders.doc(id).get();
    return _orderFromDoc(doc);
  }

  @override
  Future<OrderModel> acceptOrder(String id,
      {required double estimatedTotal}) async {
    await _orders.doc(id).update({
      'status': OrderStatus.accepted.name,
      'estimatedTotal': estimatedTotal,
    });
    final doc = await _orders.doc(id).get();
    return _orderFromDoc(doc);
  }

  @override
  Future<OrderModel> rejectOrder(String id,
      {required String reason}) async {
    await _orders.doc(id).update({
      'status': OrderStatus.rejected.name,
      'rejectionReason': reason,
    });
    final doc = await _orders.doc(id).get();
    return _orderFromDoc(doc);
  }

  @override
  Stream<List<OrderModel>> streamAllOrders() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _orderFromDoc(doc)).toList());
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
      customerAddress: data['customerAddress'] ?? '',
      category: _parseCategory(data['category']),
      itemName: data['itemName'] ?? '',
      unitType: _parseUnitType(data['unitType']),
      quantity: (data['quantity'] ?? 0).toDouble(),
      status: _parseStatus(data['status']),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      voucherCode: data['voucherCode'],
      notes: data['notes'],
      pickupDate: (data['pickupDate'] as Timestamp).toDate(),
      rejectionReason: data['rejectionReason'],
      estimatedTotal: (data['estimatedTotal'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> _orderToDoc(OrderModel order) {
    return {
      'customerId': order.customerId,
      'customerName': order.customerName,
      'customerAddress': order.customerAddress,
      'category': order.category.name,
      'itemName': order.itemName,
      'unitType': order.unitType.name,
      'quantity': order.quantity,
      'status': order.status.name,
      'totalPrice': order.totalPrice,
      'discount': order.discount,
      'voucherCode': order.voucherCode,
      'notes': order.notes,
      'pickupDate': order.pickupDate,
      'rejectionReason': order.rejectionReason,
      'estimatedTotal': order.estimatedTotal,
      'createdAt': order.createdAt,
      'completedAt': order.completedAt,
    };
  }

  OrderCategory _parseCategory(String? value) {
    return OrderCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderCategory.pakaian,
    );
  }

  UnitType _parseUnitType(String? value) {
    return UnitType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UnitType.kiloan,
    );
  }

  OrderStatus _parseStatus(String? value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.request,
    );
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';
import '../../repositories/report_repository.dart';

/// Implementasi [ReportRepository] menggunakan Cloud Firestore.
///
/// Laporan dihitung secara realtime dari data [orders] yang tersimpan.
class FirebaseReportRepository implements ReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _ordersRef => _firestore.collection('orders');
  CollectionReference get _usersRef => _firestore.collection('users');

  @override
  Future<ReportSummary> getSummary({
    required DateTime from,
    required DateTime to,
  }) async {
    final ordersInRange = await _ordersRef
        .where('createdAt', isGreaterThanOrEqualTo: from)
        .where('createdAt', isLessThanOrEqualTo: to)
        .get();

    final orders = ordersInRange.docs;

    // 🔥 FOKUS: hanya order dengan status COMPLETED
    final completedOrders = orders.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['status'] == 'completed';
    }).toList();

    // Revenue dari completed orders
    final totalRevenue = completedOrders.fold<double>(
      0.0,
      (total, doc) {
        final data = doc.data() as Map<String, dynamic>;
        final price = (data['totalPrice'] ?? 0).toDouble();
        final discount = (data['discount'] ?? 0).toDouble();
        return total + price - discount;
      },
    );

    // totalOrders = completed orders saja
    final totalOrders = completedOrders.length;

    final customerSnapshot = await _usersRef
        .where('role', isEqualTo: 'customer')
        .get();

    final newCustomers = customerSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = (data['createdAt'] as Timestamp).toDate();
      return !createdAt.isBefore(from) && !createdAt.isAfter(to);
    }).length;

    // Daily stats tetap hitung per hari dari completed orders
    final dailyStats = _computeDailyStats(completedOrders, from, to);
    final avgOrderValue =
        completedOrders.isEmpty ? 0.0 : (totalRevenue / completedOrders.length);

    // activeCustomers = unique customer yang completed order
    final completedCustomerIds = completedOrders
        .map((doc) => (doc.data() as Map<String, dynamic>)['customerId'] as String?)
        .where((id) => id != null)
        .toSet();
    final activeCustomers = completedCustomerIds.length;

    return ReportSummary(
      totalRevenue: totalRevenue,
      revenueGrowth: 0, 
      totalOrders: totalOrders,
      ordersGrowth: 0,
      newCustomers: newCustomers,
      activeCustomers: activeCustomers,
      averageOrderValue: avgOrderValue,
      dailyStats: dailyStats,
    );
  }

  @override
  Future<List<DailyStat>> getDailyStats({
    required DateTime from,
    required DateTime to,
  }) async {
    final ordersInRange = await _ordersRef
        .where('createdAt', isGreaterThanOrEqualTo: from)
        .where('createdAt', isLessThanOrEqualTo: to)
        .get();

    // 🔥 FOKUS: hanya completed orders untuk konsistensi dengan getSummary
    final completedOrders = ordersInRange.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['status'] == 'completed';
    }).toList();

    return _computeDailyStats(completedOrders, from, to);
  }

  List<DailyStat> _computeDailyStats(
    List<QueryDocumentSnapshot<Object?>> orders,
    DateTime from,
    DateTime to,
  ) {
    final Map<String, _DayAggregate> dailyMap = {};

    for (final doc in orders) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = (data['createdAt'] as Timestamp).toDate();
      final key = _dateKey(createdAt);

      dailyMap.putIfAbsent(key, () => _DayAggregate(date: createdAt));
      dailyMap[key]!.orderCount++;
      // Hanya hitung revenue dari completed orders
      final isCompleted = data['status'] == 'completed';
      if (isCompleted) {
        final rawTotal = data['totalPrice'] ?? 0;
        final rawDiscount = data['discount'] ?? 0;
        dailyMap[key]!.revenue += (rawTotal as num).toDouble() - (rawDiscount as num).toDouble();
      }
    }

    final stats = <DailyStat>[];
    var current = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);

    while (!current.isAfter(end)) {
      final key = _dateKey(current);
      final day = dailyMap[key];
      stats.add(DailyStat(
        date: current,
        orderCount: day?.orderCount ?? 0,
        revenue: day?.revenue ?? 0,
      ));
      current = current.add(const Duration(days: 1));
    }

    return stats;
  }

  @override
  Stream<List<OrderModel>> streamAllOrders() {
    return _ordersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
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
            }).toList());
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

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _DayAggregate {
  int orderCount = 0;
  double revenue = 0;
  final DateTime date;

  _DayAggregate({required this.date});
}

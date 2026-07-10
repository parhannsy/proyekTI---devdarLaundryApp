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
    final totalRevenue = orders.fold<double>(
      0.0,
      (total, doc) {
        final data = doc.data() as Map<String, dynamic>;
        final price = (data['totalPrice'] ?? 0).toDouble();
        final discount = (data['discount'] ?? 0).toDouble();
        return total + price - discount;
      },
    );

    final customerSnapshot = await _usersRef
        .where('role', isEqualTo: 'customer')
        .get();

    final newCustomers = customerSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = (data['createdAt'] as Timestamp).toDate();
      return !createdAt.isBefore(from) && !createdAt.isAfter(to);
    }).length;

    final dailyStats = _computeDailyStats(orders, from, to);
    final avgOrderValue =
        orders.isEmpty ? 0.0 : (totalRevenue / orders.length);

    return ReportSummary(
      totalRevenue: totalRevenue,
      revenueGrowth: 0, // TODO: bandingkan dengan periode sebelumnya
      totalOrders: orders.length,
      ordersGrowth: 0,
      newCustomers: newCustomers,
      activeCustomers: customerSnapshot.docs.length,
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

    return _computeDailyStats(ordersInRange.docs, from, to);
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
      final rawTotal = data['totalPrice'] ?? 0;
      final rawDiscount = data['discount'] ?? 0;
      dailyMap[key]!.revenue += (rawTotal as num).toDouble() - (rawDiscount as num).toDouble();
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

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _DayAggregate {
  int orderCount = 0;
  double revenue = 0;
  final DateTime date;

  _DayAggregate({required this.date});
}

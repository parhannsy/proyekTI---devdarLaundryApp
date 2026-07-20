import 'dart:async';
import '../models/models.dart';
import '../repositories/report_repository.dart';
import 'mock_data_store.dart';

/// Implementasi mock yang menghitung laporan dari [MockDataStore.orders].
///
/// Data order menggunakan shared store yang SAMA dengan [MockOrderRepository],
/// jadi perubahan dari halaman order langsung terlihat di laporan secara realtime.
class MockReportRepository implements ReportRepository {
  List<OrderModel> get _allOrders => MockDataStore.orders;

  @override
  Future<ReportSummary> getSummary({
    required DateTime from,
    required DateTime to,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final inRange = _allOrders
        .where((o) =>
            !o.createdAt.isBefore(from) && !o.createdAt.isAfter(to))
        .toList();

    final completedInRange = inRange
        .where((o) => o.status == OrderStatus.completed)
        .toList();

    final totalRevenue =
        completedInRange.fold<double>(0, (sum, o) => sum + o.finalPrice);
    final totalOrders = completedInRange.length;
    final avgOrderValue =
        completedInRange.isEmpty ? 0.0 : totalRevenue / completedInRange.length;

    final prevFrom = from.subtract(to.difference(from));
    final prevCompleted = _allOrders
        .where((o) =>
            !o.createdAt.isBefore(prevFrom) &&
            o.createdAt.isBefore(from) &&
            o.status == OrderStatus.completed)
        .toList();
    final prevRevenue = prevCompleted.fold<double>(
        0, (sum, o) => sum + o.finalPrice);
    final revenueGrowth =
        prevRevenue > 0 ? ((totalRevenue - prevRevenue) / prevRevenue * 100) : 0.0;

    final ordersGrowth =
        prevCompleted.isEmpty ? 0 : totalOrders - prevCompleted.length;

    final activeCustomers =
        completedInRange.map((o) => o.customerId).toSet().length;

    // Hitung newCustomers: customer yang order pertamanya di periode ini
    final allCustomerIds = _allOrders.map((o) => o.customerId).toSet();
    final newCustomerIds = allCustomerIds.where((cid) {
      final firstOrder = _allOrders
          .where((o) => o.customerId == cid)
          .fold<DateTime?>(null, (earliest, o) {
        if (earliest == null || o.createdAt.isBefore(earliest)) return o.createdAt;
        return earliest;
      });
      return firstOrder != null &&
          !firstOrder.isBefore(from) &&
          !firstOrder.isAfter(to);
    }).length;

    final dailyStats = _computeDailyStats(inRange, from, to);

    return ReportSummary(
      totalRevenue: totalRevenue,
      revenueGrowth: revenueGrowth,
      totalOrders: totalOrders,
      ordersGrowth: ordersGrowth,
      newCustomers: newCustomerIds,
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
    await Future.delayed(const Duration(milliseconds: 300));
    final inRange = _allOrders
        .where((o) =>
            !o.createdAt.isBefore(from) && !o.createdAt.isAfter(to))
        .toList();
    return _computeDailyStats(inRange, from, to);
  }

  List<DailyStat> _computeDailyStats(
      List<OrderModel> orders, DateTime from, DateTime to) {
    final Map<String, _DayAgg> dailyMap = {};

    for (final o in orders) {
      final key = _dateKey(o.createdAt);
      dailyMap.putIfAbsent(key, () => _DayAgg());
      dailyMap[key]!.orderCount++;
      dailyMap[key]!.revenue +=
          o.status == OrderStatus.completed ? o.finalPrice : 0;
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
    final controller = StreamController<List<OrderModel>>.broadcast();

    final timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!controller.isClosed) {
        controller.add(List.from(_allOrders));
      }
    });

    controller.onCancel = () => timer.cancel();

    Future.microtask(() {
      if (!controller.isClosed) {
        controller.add(List.from(_allOrders));
      }
    });

    return controller.stream;
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _DayAgg {
  int orderCount = 0;
  double revenue = 0;
}

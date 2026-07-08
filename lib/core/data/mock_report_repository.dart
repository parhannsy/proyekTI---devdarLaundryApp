import '../models/models.dart';
import '../repositories/report_repository.dart';

class MockReportRepository implements ReportRepository {
  @override
  Future<ReportSummary> getSummary({
    required DateTime from,
    required DateTime to,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return ReportSummary(
      totalRevenue: 4_850_000,
      revenueGrowth: 12.5,
      totalOrders: 127,
      ordersGrowth: 8,
      newCustomers: 23,
      activeCustomers: 89,
      averageOrderValue: 38189,
      dailyStats: _generateDailyStats(from, to),
    );
  }

  @override
  Future<List<DailyStat>> getDailyStats({
    required DateTime from,
    required DateTime to,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _generateDailyStats(from, to);
  }

  List<DailyStat> _generateDailyStats(DateTime from, DateTime to) {
    final stats = <DailyStat>[];
    final revenues = [
      185000, 220000, 175000, 310000, 265000, 195000, 240000,
      280000, 195000, 320000, 275000, 230000, 180000, 295000,
      260000, 215000, 305000, 190000, 245000, 285000, 170000,
      300000, 255000, 210000, 330000, 280000, 195000, 315000,
      270000, 225000,
    ];

    var current = from;
    int i = 0;
    while (!current.isAfter(to) && i < revenues.length) {
      stats.add(DailyStat(
        date: current,
        orderCount: (revenues[i] / 38000).round(),
        revenue: revenues[i].toDouble(),
      ));
      current = current.add(const Duration(days: 1));
      i++;
    }

    return stats;
  }
}

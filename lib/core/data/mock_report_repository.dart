import '../models/models.dart';
import '../repositories/report_repository.dart';

/// Implementasi mock yang menghitung laporan dari data order real (sama dengan MockOrderRepository).
class MockReportRepository implements ReportRepository {
  final List<OrderModel> _orders = [
    OrderModel(
      id: 'ORD-2026-001',
      customerId: 'cust-001',
      customerName: 'Ahmad Farhan',
      category: OrderCategory.pakaian,
      itemName: 'Baju & Celana',
      unitType: UnitType.kiloan,
      quantity: 3.5,
      status: OrderStatus.processing,
      totalPrice: 35000,
      pickupDate: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    OrderModel(
      id: 'ORD-2026-002',
      customerId: 'cust-001',
      customerName: 'Ahmad Farhan',
      category: OrderCategory.carpet,
      itemName: 'Karpet Ruang Tamu',
      unitType: UnitType.meteran,
      quantity: 4.0,
      status: OrderStatus.accepted,
      totalPrice: 80000,
      estimatedTotal: 80000,
      pickupDate: DateTime.now().add(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    OrderModel(
      id: 'ORD-2026-003',
      customerId: 'cust-002',
      customerName: 'Siti Rahayu',
      category: OrderCategory.pakaian,
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
      category: OrderCategory.perlengkapanKamar,
      itemName: 'Sprei & Sarung Bantal',
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
      category: OrderCategory.perlengkapanKamar,
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
      category: OrderCategory.pakaian,
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

  // Hari-hari sebelumnya untuk daily stats
  final List<OrderModel> _previousOrders = [
    OrderModel(
      id: 'ORD-2026-008',
      customerId: 'cust-001',
      customerName: 'Ahmad Farhan',
      category: OrderCategory.pakaian,
      itemName: 'Baju Sehari-hari',
      unitType: UnitType.kiloan,
      quantity: 2.0,
      status: OrderStatus.completed,
      totalPrice: 28000,
      discount: 0,
      pickupDate: DateTime.now().subtract(const Duration(days: 30)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      completedAt: DateTime.now().subtract(const Duration(days: 29)),
    ),
    OrderModel(
      id: 'ORD-2026-009',
      customerId: 'cust-002',
      customerName: 'Siti Rahayu',
      category: OrderCategory.pakaian,
      itemName: 'Seragam harian',
      unitType: UnitType.kiloan,
      quantity: 1.5,
      status: OrderStatus.completed,
      totalPrice: 22000,
      discount: 0,
      pickupDate: DateTime.now().subtract(const Duration(days: 25)),
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      completedAt: DateTime.now().subtract(const Duration(days: 24)),
    ),
  ];

  @override
  Future<ReportSummary> getSummary({
    required DateTime from,
    required DateTime to,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final allOrders = [..._orders, ..._previousOrders];
    final inRange = allOrders
        .where((o) =>
            !o.createdAt.isBefore(from) && !o.createdAt.isAfter(to))
        .toList();

    final completedInRange = inRange
        .where((o) => o.status == OrderStatus.completed)
        .toList();

    final totalRevenue =
        completedInRange.fold<double>(0, (sum, o) => sum + o.finalPrice);
    final totalOrders = inRange.length;
    final avgOrderValue =
        completedInRange.isEmpty ? 0.0 : totalRevenue / completedInRange.length;

    // Hitung periode sebelumnya (sama panjang)
    final prevFrom = from.subtract(to.difference(from));
    final prevOrders = allOrders
        .where((o) =>
            !o.createdAt.isBefore(prevFrom) && o.createdAt.isBefore(from))
        .toList();
    final prevRevenue = prevOrders.fold<double>(
        0, (sum, o) => sum + (o.status == OrderStatus.completed ? o.finalPrice : 0));
    final revenueGrowth =
        prevRevenue > 0 ? ((totalRevenue - prevRevenue) / prevRevenue * 100) : 0.0;

    final ordersGrowth =
        prevOrders.isEmpty ? 0 : totalOrders - prevOrders.length;

    // Unique customers
    final activeCustomers =
        inRange.map((o) => o.customerId).toSet().length;

    final dailyStats = _computeDailyStats(inRange, from, to);

    return ReportSummary(
      totalRevenue: totalRevenue,
      revenueGrowth: revenueGrowth,
      totalOrders: totalOrders,
      ordersGrowth: ordersGrowth,
      newCustomers: 0, // mock — gak ada data registrasi
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
    final allOrders = [..._orders, ..._previousOrders];
    final inRange = allOrders
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

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _DayAgg {
  int orderCount = 0;
  double revenue = 0;
}

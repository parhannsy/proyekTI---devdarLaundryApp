class DailyStat {
  final DateTime date;
  final int orderCount;
  final double revenue;

  const DailyStat({
    required this.date,
    required this.orderCount,
    required this.revenue,
  });
}

class ReportSummary {
  final double totalRevenue;
  final double revenueGrowth; // persentase dibanding periode sebelumnya
  final int totalOrders;
  final int ordersGrowth;
  final int newCustomers;
  final int activeCustomers;
  final double averageOrderValue;
  final List<DailyStat> dailyStats;

  const ReportSummary({
    required this.totalRevenue,
    required this.revenueGrowth,
    required this.totalOrders,
    required this.ordersGrowth,
    required this.newCustomers,
    required this.activeCustomers,
    required this.averageOrderValue,
    required this.dailyStats,
  });
}

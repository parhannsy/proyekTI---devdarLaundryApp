import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository;

  ReportSummary? _summary;
  DateTime _from;
  DateTime _to;
  bool _isLoading = false;
  String? _errorMessage;

  // Stream subscription untuk realtime update
  StreamSubscription<List<OrderModel>>? _streamSub;
  List<OrderModel> _allOrders = [];

  ReportProvider(this._repository)
      : _from = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          1,
        ),
        _to = DateTime.now();

  ReportSummary? get summary => _summary;
  DateTime get from => _from;
  DateTime get to => _to;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Revenue per kategori dari [_allOrders] (completed orders dalam rentang).
  Map<OrderCategory, double> get categoryRevenue {
    final inRange = _allOrders.where((o) {
      return !o.createdAt.isBefore(_from) && !o.createdAt.isAfter(_to) &&
          o.status == OrderStatus.completed;
    });

    final Map<OrderCategory, double> catMap = {};
    for (final o in inRange) {
      catMap.update(o.category, (v) => v + o.finalPrice, ifAbsent: () => o.finalPrice);
    }
    return catMap;
  }

  // ── Stream (Admin - realtime) ─────────────────────────────

  /// Mulai mendengarkan stream realtime order dari repository.
  /// Setiap ada perubahan data, summary akan otomatis di-recompute.
  void listenSummary() {
    _streamSub?.cancel();

    _isLoading = true;
    notifyListeners();

    _streamSub = _repository.streamAllOrders().listen(
      (updatedOrders) {
        _allOrders = updatedOrders;
        _errorMessage = null;
        _computeSummary();
      },
      onError: (Object error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
        debugPrint('[ReportProvider] Stream error: $error');
      },
    );
  }

  /// Hentikan stream — panggil saat widget di-dispose.
  void stopListening() {
    _streamSub?.cancel();
    _streamSub = null;
  }

  // ── One-time fetch (fallback) ─────────────────────────────

  Future<void> loadSummary() async {
    _setLoading(true);
    try {
      _summary = await _repository.getSummary(from: _from, to: _to);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Date range ────────────────────────────────────────────

  Future<void> changeDateRange(DateTime from, DateTime to) async {
    _from = from;
    _to = to;
    // Recompute dari cache, fallback ke fetch langsung jika cache kosong
    if (_allOrders.isNotEmpty) {
      _computeSummary();
    } else {
      await loadSummary();
    }
  }

  // ── Internal ──────────────────────────────────────────────

  /// Compute [ReportSummary] dari [_allOrders] yang sudah difilter
  /// berdasarkan [_from] dan [_to], FOKUS pada completed orders.
  void _computeSummary() {
    final inRange = _allOrders.where((o) {
      return !o.createdAt.isBefore(_from) && !o.createdAt.isAfter(_to);
    }).toList();

    final completedInRange = inRange
        .where((o) => o.status == OrderStatus.completed)
        .toList();

    final totalRevenue =
        completedInRange.fold<double>(0, (sum, o) => sum + o.finalPrice);
    final totalOrders = completedInRange.length;
    final avgOrderValue =
        completedInRange.isEmpty ? 0.0 : totalRevenue / completedInRange.length;

    // Hitung periode sebelumnya (sama panjang) — fokus completed
    final prevFrom = _from.subtract(_to.difference(_from));
    final prevCompleted = _allOrders.where((o) {
      return !o.createdAt.isBefore(prevFrom) &&
          o.createdAt.isBefore(_from) &&
          o.status == OrderStatus.completed;
    }).toList();

    final prevRevenue =
        prevCompleted.fold<double>(0, (sum, o) => sum + o.finalPrice);
    final revenueGrowth =
        prevRevenue > 0 ? ((totalRevenue - prevRevenue) / prevRevenue * 100) : 0.0;

    final ordersGrowth =
        prevCompleted.isEmpty ? 0 : totalOrders - prevCompleted.length;

    final activeCustomers =
        completedInRange.map((o) => o.customerId).toSet().length;

    // Hitung newCustomers: customer yang order pertamanya di periode ini
    final newCustomerIds = _allOrders
        .where((o) => !o.createdAt.isBefore(_from) && !o.createdAt.isAfter(_to))
        .map((o) => o.customerId)
        .toSet()
        .where((cid) {
      // Cari order pertama customer ini
      final firstOrder = _allOrders
          .where((o) => o.customerId == cid)
          .fold<DateTime?>(null, (earliest, o) {
        if (earliest == null || o.createdAt.isBefore(earliest)) return o.createdAt;
        return earliest;
      });
      return firstOrder != null &&
          !firstOrder.isBefore(_from) &&
          !firstOrder.isAfter(_to);
    }).length;

    // Daily stats hanya dari completed orders
    final dailyStats = _computeDailyStats(completedInRange, _from, _to);

    _summary = ReportSummary(
      totalRevenue: totalRevenue,
      revenueGrowth: revenueGrowth,
      totalOrders: totalOrders,
      ordersGrowth: ordersGrowth,
      newCustomers: newCustomerIds,
      activeCustomers: activeCustomers,
      averageOrderValue: avgOrderValue,
      dailyStats: dailyStats,
    );

    _isLoading = false;
    notifyListeners();
  }

  List<DailyStat> _computeDailyStats(
      List<OrderModel> orders, DateTime from, DateTime to) {
    final Map<String, _DayAgg> dailyMap = {};

    for (final o in orders) {
      final key = _dateKey(o.createdAt);
      dailyMap.putIfAbsent(key, () => _DayAgg());
      dailyMap[key]!.orderCount++;
      dailyMap[key]!.revenue += o.finalPrice;
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class _DayAgg {
  int orderCount = 0;
  double revenue = 0;
}

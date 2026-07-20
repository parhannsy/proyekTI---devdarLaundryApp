import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/providers/report_provider.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_page_header.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_stat_card.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  String _selectedPeriod = 'Bulan Ini';
  final NumberFormat _fmt = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  final NumberFormat _fmtK = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  static const _periods = ['Minggu Ini', 'Bulan Ini', '3 Bulan', 'Tahun Ini'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().listenSummary();
    });
  }

  @override
  void dispose() {
    // Bersihkan stream subscription agar tidak memory leak
    context.read<ReportProvider>().stopListening();
    super.dispose();
  }

  (DateTime, DateTime) _dateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Minggu Ini':
        final start = now.subtract(Duration(days: now.weekday - 1));
        return (DateTime(start.year, start.month, start.day), now);
      case 'Bulan Ini':
        return (DateTime(now.year, now.month, 1), now);
      case '3 Bulan':
        return (DateTime(now.year, now.month - 2, 1), now);
      case 'Tahun Ini':
        return (DateTime(now.year, 1, 1), now);
      default:
        return (DateTime(now.year, now.month, 1), now);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          final summary = provider.summary;
          final dailyStats = summary?.dailyStats ?? [];

          return RefreshIndicator(
            onRefresh: () => provider.loadSummary(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                // ── Header + Period Filter ──
                AnimatedFadeSlider(
                  index: 1,                    child: AdminPageHeader(
                    title: 'Laporan',
                    subtitle: provider.isLoading
                        ? 'Memuat data...'
                        : '📊 Fokus pada pesanan yang sudah selesai',
                    actions: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColor.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPeriod,
                            isDense: true,
                            style: const TextStyle(
                              fontSize: 13, color: AppColor.textPrimary,
                            ),
                            items: _periods
                                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                .toList(),
                            onChanged: (v) {
                              setState(() => _selectedPeriod = v!);
                              final (from, to) = _dateRange();
                              provider.changeDateRange(from, to);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Loading ──
                if (provider.isLoading && summary == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                // ── Error ──
                if (provider.errorMessage != null && summary == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColor.error),
                        const SizedBox(height: 12),
                        const Text('Gagal memuat laporan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => provider.loadSummary(),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),

                // ── Content ──
                if (summary != null) ...[
                  // KPI cards
                  AnimatedFadeSlider(
                    index: 2,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth > 600 ? 4 : 2;
                        final s = summary;
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: cols,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: cols == 4 ? 1.1 : 1.0,
                          children: [
                            AdminStatCard(
                              title: 'Pendapatan (Selesai)',
                              value: _fmt.format(s.totalRevenue),
                              subtitle: 'Dari pesanan selesai',
                              icon: Icons.attach_money_rounded,
                              color: AppColor.success,
                              growthPercent: s.revenueGrowth,
                            ),
                            AdminStatCard(
                              title: 'Pesanan Selesai',
                              value: '${s.totalOrders}',
                              subtitle: 'Completed orders',
                              icon: Icons.task_alt_rounded,
                              color: AppColor.primary,
                              growthPercent: s.ordersGrowth.toDouble(),
                            ),
                            AdminStatCard(
                              title: 'Rata-rata/Order',
                              value: _fmt.format(s.averageOrderValue),
                              subtitle: 'Per pesanan selesai',
                              icon: Icons.calculate_outlined,
                              color: AppColor.info,
                              growthPercent: null,
                            ),
                            AdminStatCard(
                              title: 'Pelanggan (Selesai)',
                              value: '${s.activeCustomers}',
                              subtitle: 'Dengan order selesai',
                              icon: Icons.people_outline,
                              color: AppColor.warning,
                              growthPercent: null,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bar chart
                  if (dailyStats.isNotEmpty)
                    AnimatedFadeSlider(
                      index: 3,
                      child: _buildBarChart(dailyStats),
                    ),

                  const SizedBox(height: 20),

                  // Category breakdown
                  AnimatedFadeSlider(
                    index: 4,
                    child: _buildCategoryBreakdown(provider, summary),
                  ),

                  const SizedBox(height: 20),

                  // Ringkasan
                  AnimatedFadeSlider(
                    index: 5,
                    child: _buildRingkasan(summary),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Bar Chart ──────────────────────────────────────────────

  Widget _buildBarChart(List<DailyStat> stats) {
    final last7 = stats.length > 7 ? stats.sublist(stats.length - 7) : stats;
    final maxVal = last7.fold<double>(0, (m, s) => s.revenue > m ? s.revenue : m);
    final dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pendapatan Harian',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColor.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '7 hari terakhir',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColor.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: last7.asMap().entries.map((entry) {
                final stat = entry.value;
                final ratio = maxVal > 0 ? stat.revenue / maxVal : 0.0;
                final dayName = dayNames[stat.date.weekday % 7];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _fmtK.format(stat.revenue),
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppColor.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: 100 * ratio,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [AppColor.primary, AppColor.primaryDark],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Breakdown ────────────────────────────────────

  Widget _buildCategoryBreakdown(ReportProvider provider, ReportSummary summary) {
    final catRevenue = provider.categoryRevenue;
    final totalCatRevenue = catRevenue.values.fold<double>(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pendapatan per Kategori',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (catRevenue.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Belum ada data kategori',
                    style: TextStyle(color: AppColor.textMuted, fontSize: 13)),
              ),
            )
          else
            ...catRevenue.entries.map((entry) {
              final percentage = totalCatRevenue > 0 ? entry.value / totalCatRevenue : 0.0;
              return _CategoryRow(
                data: _CategoryData(
                  name: entry.key.label,
                  percentage: percentage,
                  revenue: _fmt.format(entry.value),
                  color: _categoryColor(entry.key),
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _categoryColor(OrderCategory cat) {
    switch (cat) {
      case OrderCategory.pakaian:
        return AppColor.primary;
      case OrderCategory.carpet:
        return AppColor.warning;
      case OrderCategory.shoes:
        return AppColor.info;
      case OrderCategory.perlengkapanKamar:
        return const Color(0xFFAB47BC);
    }
  }

  // ── Top Customers ─────────────────────────────────────────

  Widget _buildRingkasan(ReportSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Ringkasan Pesanan Selesai',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColor.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: AppColor.success),
                    SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColor.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _summaryRow('Pesanan Selesai', '${summary.totalOrders}', Icons.task_alt_rounded, iconColor: AppColor.primary),
          _summaryRow('Pendapatan', _fmt.format(summary.totalRevenue), Icons.attach_money_rounded, iconColor: AppColor.success),
          _summaryRow('Rata-rata/Order', _fmt.format(summary.averageOrderValue), Icons.calculate_outlined, iconColor: AppColor.info),
          _summaryRow('Pelanggan', '${summary.activeCustomers}', Icons.people_outline, iconColor: AppColor.warning),
          if (summary.newCustomers > 0)
            _summaryRow('Pelanggan Baru', '${summary.newCustomers}', Icons.person_add_outlined, iconColor: AppColor.success),
          if (summary.revenueGrowth != 0)
            _summaryRow(
              'Pertumbuhan Revenue',
              '${summary.revenueGrowth.toStringAsFixed(1)}%',
              summary.revenueGrowth > 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              valueColor: summary.revenueGrowth > 0 ? AppColor.success : AppColor.error,
              iconColor: summary.revenueGrowth > 0 ? AppColor.success : AppColor.error,
            ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, IconData icon, {Color? valueColor, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? AppColor.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
          ),
          Text(value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppColor.textPrimary,
              )),
        ],
      ),
    );
  }
}

// ─── Category Row Widget ─────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final _CategoryData data;
  const _CategoryRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: data.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(data.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.textPrimary)),
              ),
              Text('${(data.percentage * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, color: AppColor.textSecondary)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(data.revenue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: data.color)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.percentage,
              backgroundColor: AppColor.progressBackground,
              valueColor: AlwaysStoppedAnimation<Color>(data.color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryData {
  final String name, revenue;
  final double percentage;
  final Color color;
  const _CategoryData({
    required this.name,
    required this.percentage,
    required this.revenue,
    required this.color,
  });
}

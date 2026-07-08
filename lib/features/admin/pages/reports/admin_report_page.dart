import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/animated_fade_slider.dart';
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

  static const _periods = ['Minggu Ini', 'Bulan Ini', '3 Bulan', 'Tahun Ini'];

  // Dummy revenue data for bar chart (7 days)
  static const _barData = [185.0, 310.0, 265.0, 195.0, 240.0, 280.0, 320.0];
  static const _barLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  // Category breakdown
  static const _categories = [
    _CategoryData(
      name: 'Reguler',
      percentage: 0.45,
      revenue: 'Rp 2,18 jt',
      color: AppColor.primary,
    ),
    _CategoryData(
      name: 'Express',
      percentage: 0.25,
      revenue: 'Rp 1,21 jt',
      color: AppColor.success,
    ),
    _CategoryData(
      name: 'Karpet',
      percentage: 0.15,
      revenue: 'Rp 0,73 jt',
      color: AppColor.warning,
    ),
    _CategoryData(
      name: 'Sepatu',
      percentage: 0.10,
      revenue: 'Rp 0,49 jt',
      color: AppColor.info,
    ),
    _CategoryData(
      name: 'Dry Clean',
      percentage: 0.05,
      revenue: 'Rp 0,24 jt',
      color: Color(0xFFAB47BC),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            AnimatedFadeSlider(
              index: 1,
              child: AdminPageHeader(
                title: 'Laporan',
                subtitle: 'Ringkasan performa bisnis',
                actions: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
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
                          fontSize: 13,
                          color: AppColor.textPrimary,
                        ),
                        items: _periods
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedPeriod = v!),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // KPI cards
            AnimatedFadeSlider(
              index: 2,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth > 600 ? 4 : 2;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: cols == 4 ? 1.4 : 1.3,
                    children: const [
                      AdminStatCard(
                        title: 'Pendapatan',
                        value: 'Rp 4,85 jt',
                        icon: Icons.attach_money_rounded,
                        color: AppColor.success,
                        growthPercent: 12.5,
                      ),
                      AdminStatCard(
                        title: 'Total Order',
                        value: '127',
                        icon: Icons.inventory_2_outlined,
                        color: AppColor.primary,
                        growthPercent: 8.0,
                      ),
                      AdminStatCard(
                        title: 'Rata-rata/Order',
                        value: 'Rp 38.2K',
                        icon: Icons.calculate_outlined,
                        color: AppColor.info,
                        growthPercent: 4.3,
                      ),
                      AdminStatCard(
                        title: 'Diskon Diberikan',
                        value: 'Rp 420K',
                        icon: Icons.discount_outlined,
                        color: AppColor.warning,
                        growthPercent: -1.2,
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Bar chart
            AnimatedFadeSlider(index: 3, child: _buildBarChart()),

            const SizedBox(height: 20),

            // Category breakdown
            AnimatedFadeSlider(index: 4, child: _buildCategoryBreakdown()),

            const SizedBox(height: 20),

            // Top customers
            AnimatedFadeSlider(index: 5, child: _buildTopCustomers()),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final maxVal = _barData.reduce((a, b) => a > b ? a : b);

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
                child: const Text(
                  'x Rp 1.000',
                  style: TextStyle(
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
              children: List.generate(_barData.length, (i) {
                final ratio = _barData[i] / maxVal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${_barData[i].toInt()}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColor.textSecondary,
                          ),
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
                          _barLabels[i],
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
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
          const Divider(height: 20),
          ..._categories.map((c) => _CategoryRow(data: c)),
        ],
      ),
    );
  }

  Widget _buildTopCustomers() {
    final tops = [
      _TopCustomer(
        name: 'Ahmad Farhan',
        orders: 14,
        spent: 'Rp 485.000',
        tier: 'Gold',
      ),
      _TopCustomer(
        name: 'Dewi Kusuma',
        orders: 11,
        spent: 'Rp 380.000',
        tier: 'Gold',
      ),
      _TopCustomer(
        name: 'Siti Rahayu',
        orders: 7,
        spent: 'Rp 245.000',
        tier: 'Silver',
      ),
    ];

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
            'Top Pelanggan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColor.textPrimary,
            ),
          ),
          const Divider(height: 20),
          ...tops.asMap().entries.map(
            (e) => _TopCustomerRow(rank: e.key + 1, data: e.value),
          ),
        ],
      ),
    );
  }
}

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
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: data.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColor.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${(data.percentage * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColor.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                data.revenue,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: data.color,
                ),
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

class _TopCustomerRow extends StatelessWidget {
  final int rank;
  final _TopCustomer data;
  const _TopCustomerRow({required this.rank, required this.data});

  @override
  Widget build(BuildContext context) {
    final rankColors = [
      const Color(0xFFFFD700),
      Colors.grey,
      const Color(0xFFCD7F32),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rankColors[rank - 1].withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: rankColors[rank - 1],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${data.orders}x order',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.spent,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColor.success,
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

class _TopCustomer {
  final String name, spent, tier;
  final int orders;
  const _TopCustomer({
    required this.name,
    required this.orders,
    required this.spent,
    required this.tier,
  });
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/router/app_router.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_stat_card.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_page_header.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.currentUser?.name ?? 'Admin Devdara';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                AnimatedFadeSlider(
                  index: 1,
                  child: AdminPageHeader(
                    title: 'Dashboard',
                    subtitle: 'Selamat datang, $userName',
                  ),
                ),

                // Stat cards grid
                AnimatedFadeSlider(
                  index: 2,
                  child: _buildStatGrid(context, isWide),
                ),

                const SizedBox(height: 24),

                // Recent orders + quick actions
                AnimatedFadeSlider(
                  index: 3,
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildRecentOrders(context),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildQuickActions(context),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildRecentOrders(context),
                            const SizedBox(height: 16),
                            _buildQuickActions(context),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                // Status summary
                AnimatedFadeSlider(
                  index: 4,
                  child: _buildStatusSummary(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context, bool isWide) {
    final stats = [
      const AdminStatCard(
        title: 'Total Pendapatan',
        value: 'Rp 4,85 jt',
        subtitle: 'Bulan ini',
        icon: Icons.attach_money_rounded,
        color: AppColor.success,
        growthPercent: 12.5,
      ),
      const AdminStatCard(
        title: 'Total Order',
        value: '127',
        subtitle: 'Bulan ini',
        icon: Icons.inventory_2_outlined,
        color: AppColor.primary,
        growthPercent: 8.0,
      ),
      const AdminStatCard(
        title: 'Pelanggan Aktif',
        value: '89',
        subtitle: 'Dari 105 total',
        icon: Icons.people_outline,
        color: AppColor.info,
        growthPercent: 5.2,
      ),
      const AdminStatCard(
        title: 'Pelanggan Baru',
        value: '23',
        subtitle: 'Bulan ini',
        icon: Icons.person_add_outlined,
        color: AppColor.warning,
        growthPercent: -2.1,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isWide ? 1.1 : 1.0,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) => stats[i],
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    final orders = [
      _DashOrderRow(
        id: 'ORD-042',
        name: 'Ahmad Farhan',
        type: 'Reguler 3.5kg',
        status: 'Dicuci',
        color: AppColor.info,
      ),
      _DashOrderRow(
        id: 'ORD-041',
        name: 'Ahmad Farhan',
        type: 'Karpet 2pcs',
        status: 'Diterima',
        color: AppColor.warning,
      ),
      _DashOrderRow(
        id: 'ORD-040',
        name: 'Siti Rahayu',
        type: 'Express 2kg',
        status: 'Siap',
        color: AppColor.success,
      ),
      _DashOrderRow(
        id: 'ORD-037',
        name: 'Dewi Kusuma',
        type: 'Reguler 4kg',
        status: 'Disetrika',
        color: AppColor.primaryLight,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Terkini',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColor.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.adminOrders),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 12, color: AppColor.primary),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          ...orders.map((o) => _buildOrderRow(o)),
        ],
      ),
    );
  }

  Widget _buildOrderRow(_DashOrderRow o) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: o.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_laundry_service_outlined,
              color: AppColor.primaryLight,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o.id,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${o.name} • ${o.type}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColor.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: o.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                o.status,
                style: TextStyle(
                  fontSize: 11,
                  color: o.color,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.add_circle_outline,
        label: 'Buat Order',
        color: AppColor.primary,
        route: AppRoutes.adminOrders,
      ),
      _QuickAction(
        icon: Icons.confirmation_number_outlined,
        label: 'Buat Voucher',
        color: AppColor.success,
        route: AppRoutes.adminVouchers,
      ),
      _QuickAction(
        icon: Icons.track_changes_outlined,
        label: 'Kelola Misi',
        color: AppColor.warning,
        route: AppRoutes.adminMissions,
      ),
      _QuickAction(
        icon: Icons.bar_chart_rounded,
        label: 'Lihat Laporan',
        color: AppColor.info,
        route: AppRoutes.adminReports,
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
            'Aksi Cepat',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColor.textPrimary,
            ),
          ),
          const Divider(height: 16),
          ...actions.map(
            (a) => InkWell(
              onTap: () => context.go(a.route),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: a.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(a.icon, color: a.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      a.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColor.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary(BuildContext context) {
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
            'Ringkasan Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColor.textPrimary,
            ),
          ),
          const Divider(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatusChip(label: 'Menunggu', count: 3, color: AppColor.warning),
              _StatusChip(label: 'Diproses', count: 8, color: AppColor.info),
              _StatusChip(label: 'Siap', count: 5, color: AppColor.success),
              _StatusChip(
                label: 'Selesai Hari Ini',
                count: 12,
                color: AppColor.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashOrderRow {
  final String id, name, type, status;
  final Color color;
  const _DashOrderRow({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.color,
  });
}

class _QuickAction {
  final IconData icon;
  final String label, route;
  final Color color;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($count)',
            style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

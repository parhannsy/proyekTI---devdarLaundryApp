import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/router/app_router.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/core/providers/order_provider.dart';
import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_stat_card.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_page_header.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final NumberFormat _fmt = NumberFormat.compactCurrency(locale: 'id', symbol: 'Rp ', decimalDigits: 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().listenAllOrders();
    });
  }

  @override
  void dispose() {
    context.read<OrderProvider>().stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.currentUser?.name ?? 'Admin Devdara';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<OrderProvider>(
        builder: (context, orderProv, _) {
          final orders = orderProv.orders;
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return RefreshIndicator(
                onRefresh: () => orderProv.loadAllOrders(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      AnimatedFadeSlider(
                        index: 1,
                        child: AdminPageHeader(
                          title: 'Dashboard',
                          subtitle: orderProv.isLoading
                              ? 'Memuat data...'
                              : 'Selamat datang, $userName',
                        ),
                      ),

                      // Stat cards grid — real data
                      AnimatedFadeSlider(
                        index: 2,
                        child: _buildStatGrid(context, isWide, orders),
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
                                    child: _buildRecentOrders(context, orders),
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
                                  _buildRecentOrders(context, orders),
                                  const SizedBox(height: 16),
                                  _buildQuickActions(context),
                                ],
                              ),
                      ),

                      const SizedBox(height: 24),

                      // Status summary — real data
                      AnimatedFadeSlider(
                        index: 4,
                        child: _buildStatusSummary(context, orderProv, orders),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Stat Cards ─────────────────────────────────────────────

  Widget _buildStatGrid(BuildContext context, bool isWide, List<OrderModel> orders) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // Pendapatan bulan ini dari completed orders
    final thisMonthRevenue = orders
        .where((o) =>
            o.status == OrderStatus.completed &&
            o.completedAt != null &&
            !o.completedAt!.isBefore(monthStart))
        .fold<double>(0, (sum, o) => sum + o.finalPrice);

    // Total order bulan ini
    final thisMonthOrders = orders
        .where((o) => !o.createdAt.isBefore(monthStart))
        .length;

    // Unique customers
    final allCustomers = orders.map((o) => o.customerId).toSet().length;
    final activeMonthCustomers = orders
        .where((o) => !o.createdAt.isBefore(monthStart))
        .map((o) => o.customerId)
        .toSet()
        .length;

    // Growth dibanding bulan lalu
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthOrders = orders
        .where((o) =>
            !o.createdAt.isBefore(lastMonthStart) && o.createdAt.isBefore(monthStart))
        .length;
    final lastMonthRevenue = orders
        .where((o) =>
            o.status == OrderStatus.completed &&
            o.completedAt != null &&
            !o.completedAt!.isBefore(lastMonthStart) &&
            o.completedAt!.isBefore(monthStart))
        .fold<double>(0, (sum, o) => sum + o.finalPrice);

    final revenueGrowth = lastMonthRevenue > 0
        ? ((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue * 100)
        : 0.0;
    final orderGrowth = lastMonthOrders > 0
        ? ((thisMonthOrders - lastMonthOrders) / lastMonthOrders * 100)
        : 0.0;

    // Pelanggan baru bulan ini (perkiraan dari first order)
    final newCustomerIds = <String>{};
    for (final o in orders) {
      if (!o.createdAt.isBefore(monthStart) && !o.createdAt.isAfter(now)) {
        // Cek apakah ini order pertama customer ini
        final firstOrder = orders
            .where((co) => co.customerId == o.customerId)
            .fold<DateTime?>(null, (earliest, co) {
          if (earliest == null || co.createdAt.isBefore(earliest)) return co.createdAt;
          return earliest;
        });
        if (firstOrder != null && !firstOrder.isBefore(monthStart)) {
          newCustomerIds.add(o.customerId);
        }
      }
    }

    final stats = [
      AdminStatCard(
        title: 'Pendapatan (Bulan Ini)',
        value: _fmt.format(thisMonthRevenue),                        subtitle: 'Dari $thisMonthOrders pesanan',
        icon: Icons.attach_money_rounded,
        color: AppColor.success,
        growthPercent: revenueGrowth,
      ),
      AdminStatCard(
        title: 'Total Order',
        value: '$thisMonthOrders',
        subtitle: orders.isEmpty ? 'Memuat...' : 'Bulan ini',
        icon: Icons.inventory_2_outlined,
        color: AppColor.primary,
        growthPercent: orderGrowth,
      ),
      AdminStatCard(
        title: 'Pelanggan Aktif',
        value: '$activeMonthCustomers',
        subtitle: 'Dari $allCustomers total',
        icon: Icons.people_outline,
        color: AppColor.info,
        growthPercent: null,
      ),
      AdminStatCard(
        title: 'Pelanggan Baru',
        value: '${newCustomerIds.length}',
        subtitle: 'Bulan ini',
        icon: Icons.person_add_outlined,
        color: AppColor.warning,
        growthPercent: null,
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

  // ── Recent Orders ──────────────────────────────────────────

  /// Urutan prioritas status: Permohonan → Diterima → Diproses → Diantar → Selesai
  int _statusPriority(OrderStatus status) {
    switch (status) {
      case OrderStatus.request:
        return 0;
      case OrderStatus.accepted:
        return 1;
      case OrderStatus.pickedUp:
        return 2;
      case OrderStatus.processing:
        return 3;
      case OrderStatus.delivering:
        return 4;
      case OrderStatus.completed:
        return 5;
      default:
        return 9; // rejected, cancelled di belakang
    }
  }

  Widget _buildRecentOrders(BuildContext context, List<OrderModel> orders) {
    // Urutkan: Permohonan → Diterima → Diproses → Diantar → Selesai
    final sorted = List<OrderModel>.from(orders)
      ..sort((a, b) => _statusPriority(a.status).compareTo(_statusPriority(b.status)));
    final recent = sorted.length > 5 ? sorted.sublist(0, 5) : sorted;

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
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada pesanan',
                  style: TextStyle(color: AppColor.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ...recent.map((o) => _buildOrderRow(o)),
        ],
      ),
    );
  }

  Widget _buildOrderRow(OrderModel o) {
    final (statusLabel, statusColor) = _statusDisplay(o.status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              o.status.iconData,
              color: statusColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o.itemName,
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
                  '${o.customerName} • ${o.quantityLabel}',
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
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
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

  (String, Color) _statusDisplay(OrderStatus status) {
    switch (status) {
      case OrderStatus.request:
        return ('Permohonan', AppColor.warning);
      case OrderStatus.accepted:
        return ('Diterima', AppColor.info);
      case OrderStatus.rejected:
        return ('Ditolak', AppColor.error);
      case OrderStatus.pickedUp:
        return ('Diangkut', AppColor.warning);
      case OrderStatus.processing:
        return ('Diproses', AppColor.primaryLight);
      case OrderStatus.delivering:
        return ('Diantar', AppColor.warning);
      case OrderStatus.completed:
        return ('Selesai', AppColor.success);
      case OrderStatus.cancelled:
        return ('Batal', AppColor.error);
    }
  }

  // ── Quick Actions ──────────────────────────────────────────

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

  // ── Status Summary ─────────────────────────────────────────

  Widget _buildStatusSummary(BuildContext context, OrderProvider orderProv, List<OrderModel> orders) {
    final now = DateTime.now();
    final todayCompleted = orders
        .where((o) =>
            o.status == OrderStatus.completed &&
            o.completedAt != null &&
            o.completedAt!.year == now.year &&
            o.completedAt!.month == now.month &&
            o.completedAt!.day == now.day)
        .length;

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
              _StatusChip(label: 'Menunggu', count: orderProv.pendingCount, color: AppColor.warning),
              _StatusChip(label: 'Diproses', count: orderProv.processingCount, color: AppColor.info),
              _StatusChip(label: 'Diantar', count: orderProv.deliveringCount, color: AppColor.primaryLight),
              _StatusChip(label: 'Selesai Hari Ini', count: todayCompleted, color: AppColor.success),
            ],
          ),
        ],
      ),
    );
  }
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

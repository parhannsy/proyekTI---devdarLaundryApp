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
import 'package:devdar_laundry_pos_app/features/shared/widgets/order_toast.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final NumberFormat _fmt = NumberFormat.compactCurrency(locale: 'id', symbol: 'Rp ', decimalDigits: 1);
  int _prevRequestCount = 0;
  bool _initialLoad = true;

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
    return Consumer<OrderProvider>(
      builder: (context, orderProv, _) {
        final orders = orderProv.orders;

        // ── Deteksi permohonan baru (di luar build) ──
        if (!orderProv.isLoading && orders.isNotEmpty) {
          final currentRequestCount =
              orders.where((o) => o.status == OrderStatus.request).length;
          final countChanged = currentRequestCount != _prevRequestCount;

          if (countChanged) {
            final newRequests = currentRequestCount - _prevRequestCount;
            _prevRequestCount = currentRequestCount;

            if (newRequests > 0 && !_initialLoad) {
              // Tunda ke post-frame agar tidak error "setState during build"
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  OrderToastService.showRequestToast(context, newRequests);
                }
              });
            }

            if (_initialLoad) {
              _initialLoad = false;
            }
          }
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return RefreshIndicator(
              onRefresh: () => orderProv.loadAllOrders(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                      child: _buildStatGrid(constraints, isWide, orders),
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
    );
  }

  // ── Stat Cards ─────────────────────────────────────────────

  Widget _buildStatGrid(BoxConstraints constraints, bool isWide, List<OrderModel> orders) {
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

  // ── Recent Orders (hanya permohonan) ───────────────────────

  Widget _buildRecentOrders(BuildContext context, List<OrderModel> orders) {
    // Filter: hanya permohonan, urut dari paling lama
    final requests = List<OrderModel>.from(
      orders.where((o) => o.status == OrderStatus.request),
    )..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final displayLimit = 5;
    final displayOrders =
        requests.length > displayLimit ? requests.sublist(0, displayLimit) : requests;
    final hasOverflow = requests.length > displayLimit;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Order Terkini',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  if (requests.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColor.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${requests.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColor.warning,
                        ),
                      ),
                    ),
                  ],
                ],
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
          const Divider(height: 12),

          // ── List (scrollable jika overflow) ────
          if (displayOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada permohonan masuk',
                  style: TextStyle(color: AppColor.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: hasOverflow ? 5 * 64.0 : displayOrders.length * 64.0,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: hasOverflow
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: displayOrders.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 8, endIndent: 8),
                itemBuilder: (_, i) => _buildRequestRow(context, displayOrders[i]),
              ),
            ),

          // ── Overflow indicator ─────────────────
          if (hasOverflow)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '+${requests.length - displayLimit} permohonan lagi',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColor.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRequestRow(BuildContext context, OrderModel order) {
    final timeStr = DateFormat('HH:mm', 'id').format(order.createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          // ── Info ───────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.itemName.isNotEmpty ? order.itemName : order.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.customerName} • ${order.quantityLabel} • $timeStr',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Tombol Tolak ───────────────────────
          SizedBox(
            width: 34,
            height: 34,
            child: IconButton(
              onPressed: () => _showRejectDialog(context, order),
              icon: const Icon(Icons.close_rounded, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: AppColor.error.withValues(alpha: 0.1),
                foregroundColor: AppColor.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              padding: EdgeInsets.zero,
              tooltip: 'Tolak',
            ),
          ),
          const SizedBox(width: 6),

          // ── Tombol Terima ──────────────────────
          SizedBox(
            width: 34,
            height: 34,
            child: IconButton(
              onPressed: () => _showAcceptDialog(context, order),
              icon: const Icon(Icons.check_rounded, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: AppColor.success.withValues(alpha: 0.1),
                foregroundColor: AppColor.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              padding: EdgeInsets.zero,
              tooltip: 'Terima',
            ),
          ),
        ],
      ),
    );
  }

  // ── Accept Dialog ──────────────────────────────────────────

  void _showAcceptDialog(BuildContext context, OrderModel order) {
    final provider = context.read<OrderProvider>();
    final totalCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terima Permohonan'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${order.customerName} — ${order.itemName}',
                style: const TextStyle(fontSize: 13, color: AppColor.textSecondary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: totalCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Estimasi Biaya (Rp)',
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                    color: AppColor.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Masukkan estimasi biaya';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Biaya harus > 0';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final total = double.parse(totalCtrl.text);
              provider.acceptRequest(order.id, estimatedTotal: total);
              Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${order.id} diterima'),
                    backgroundColor: AppColor.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.success),
            child: const Text('Terima', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Reject Dialog ──────────────────────────────────────────

  void _showRejectDialog(BuildContext context, OrderModel order) {
    final provider = context.read<OrderProvider>();
    final reasonCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Permohonan'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Alasan penolakan akan dikirim ke customer.',
                style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Alasan',
                  hintText: 'Contoh: Lokasi di luar jangkauan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Alasan wajib diisi' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              provider.rejectRequest(order.id, reason: reasonCtrl.text.trim());
              Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ ${order.id} ditolak'),
                    backgroundColor: AppColor.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.error),
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

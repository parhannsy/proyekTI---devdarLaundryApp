import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/providers/order_provider.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/order_detail_sheet.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/currency_formatter.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/date_formatter.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_page_header.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_empty_state.dart';
import 'package:go_router/go_router.dart';
import 'package:devdar_laundry_pos_app/core/router/app_router.dart';

class AdminOrderPage extends StatefulWidget {
  const AdminOrderPage({super.key});

  @override
  State<AdminOrderPage> createState() => _AdminOrderPageState();
}

class _AdminOrderPageState extends State<AdminOrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const _tabLabels = [
    'Semua',
    'Permohonan',
    'Diproses',
    'Diantar',
    'Gagal',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrderProvider>();
      provider.addListener(_onOrdersChanged);
      _syncOrders(provider);
      provider.listenAllOrders();

    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    try {
      final provider = context.read<OrderProvider>();
      provider.removeListener(_onOrdersChanged);
      provider.stopListening();
    } catch (_) {}
    super.dispose();
  }

  void _onOrdersChanged() {
    if (!mounted) return;
    final provider = context.read<OrderProvider>();
    _syncOrders(provider);
  }

  void _syncOrders(OrderProvider provider) {
    setState(() {
      _orders = provider.orders;
      _isLoading = provider.isLoading;
      _errorMessage = provider.errorMessage;
    });
  }

  void _onTabChanged() {
    // Force rebuild saat tab berganti (tanpa stream trigger)
    setState(() {});
  }

  OrderStatusColor _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.request:
        return OrderStatusColor(AppColor.warning, AppColor.warning.withValues(alpha: 0.1));
      case OrderStatus.accepted:
        return OrderStatusColor(AppColor.success, AppColor.success.withValues(alpha: 0.1));
      case OrderStatus.rejected:
        return OrderStatusColor(AppColor.error, AppColor.error.withValues(alpha: 0.1));
      case OrderStatus.pickedUp:
        return OrderStatusColor(AppColor.info, AppColor.info.withValues(alpha: 0.1));
      case OrderStatus.processing:
        return OrderStatusColor(const Color(0xFF2196F3), const Color(0xFF2196F3).withValues(alpha: 0.1));
      case OrderStatus.delivering:
        return OrderStatusColor(const Color(0xFFFF9800), const Color(0xFFFF9800).withValues(alpha: 0.1));
      case OrderStatus.completed:
        return OrderStatusColor(AppColor.success, AppColor.success.withValues(alpha: 0.1));
      case OrderStatus.cancelled:
        return OrderStatusColor(AppColor.textMuted, AppColor.textMuted.withValues(alpha: 0.1));
    }
  }

  List<OrderModel> _filterByTab(String tab) {
    if (tab == 'Semua') {
      // Semua order kecuali yang sudah selesai
      return _orders.where((o) => o.status != OrderStatus.completed).toList();
    }
    switch (tab) {
      case 'Permohonan':
        return _orders.where((o) => o.status == OrderStatus.request).toList();
      case 'Diproses':
        return _orders
            .where((o) =>
                o.status == OrderStatus.processing ||
                o.status == OrderStatus.pickedUp)
            .toList();
      case 'Diantar':
        return _orders.where((o) => o.status == OrderStatus.delivering).toList();
      case 'Gagal':
        return _orders
            .where((o) =>
                o.status == OrderStatus.cancelled ||
                o.status == OrderStatus.rejected)
            .toList();
      default:
        return _orders;
    }
  }

  bool _matchesSearch(OrderModel o) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return o.id.toLowerCase().contains(q) ||
        o.customerName.toLowerCase().contains(q) ||
        o.category.label.toLowerCase().contains(q);
  }

  // ── Dialogs ───────────────────────────────────────────────

  void _showAcceptDialog(OrderModel order) {
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
              Text('${order.customerName} — ${order.category.label}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColor.textSecondary)),
              const SizedBox(height: 16),
              TextFormField(
                controller: totalCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Estimasi Biaya (Rp)',
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                      color: AppColor.textPrimary,
                      fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ ${order.id} diterima'),
                  backgroundColor: AppColor.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.success),
            child: const Text('Terima',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(OrderModel order) {
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
              const Text('Alasan penolakan akan dikirim ke customer.',
                  style:
                      TextStyle(fontSize: 13, color: AppColor.textSecondary)),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Alasan',
                  hintText: 'Contoh: Lokasi di luar jangkauan',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ ${order.id} ditolak'),
                  backgroundColor: AppColor.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.error),
            child: const Text('Tolak',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _advanceStatus(OrderModel order) {
    final provider = context.read<OrderProvider>();
    final next = orderNextStatus(order.status);
    if (next == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Status'),
        content: Text(
          '${order.id}\n'
          '${order.status.label} → ${next.label}\n\n'
          'Lanjutkan ke tahap berikutnya?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateStatus(order.id, next);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${order.id} → ${next.label}'),
                  backgroundColor: AppColor.info,
                ),
              );
            },
            child: Text('➡️ ${next.label}'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null && _orders.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColor.error),
                const SizedBox(height: 16),
                const Text('Gagal memuat pesanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.read<OrderProvider>().listenAllOrders(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final requestCount = _orders.where((o) => o.status == OrderStatus.request).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── Header ──────────────────────
          AnimatedFadeSlider(
            index: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: AdminPageHeader(
                title: 'Kelola Pesanan',
                subtitle: '$requestCount permohonan baru',
              ),
            ),
          ),

          // ── Search + History button ──
          AnimatedFadeSlider(
            index: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Cari ID, nama pelanggan...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColor.textMuted),
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppColor.iconSecondary),
                        filled: true,
                        fillColor: AppColor.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.adminHistory),
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text(
                        'Riwayat',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.surface,
                        foregroundColor: AppColor.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColor.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Tab bar ──────────────────────
          AnimatedFadeSlider(
            index: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColor.textSecondary,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                tabAlignment: TabAlignment.start,
                tabs: _tabLabels.map((s) => Tab(text: s)).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Content — TabBarView STABIL (tidak di-recreate) ─
          Expanded(
            child: _isLoading && _orders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: _tabLabels.map((tab) {
                      final tabOrders = _filterByTab(tab)
                          .where((o) => _matchesSearch(o))
                          .toList();
                      return _OrderListView(
                        key: ValueKey('admin_tab_$tab'),
                        orders: tabOrders,
                        statusColorFn: _statusColor,
                        onAccept: (o) => _showAcceptDialog(o),
                        onReject: (o) => _showRejectDialog(o),
                        onAdvance: (o) => _advanceStatus(o),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Order List View ──────────────────────────────────────────

class _OrderListView extends StatelessWidget {
  final List<OrderModel> orders;
  final OrderStatusColor Function(OrderStatus) statusColorFn;
  final void Function(OrderModel)? onAccept;
  final void Function(OrderModel)? onReject;
  final void Function(OrderModel)? onAdvance;

  const _OrderListView({
    super.key,
    required this.orders,
    required this.statusColorFn,
    this.onAccept,
    this.onReject,
    this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Belum ada pesanan',
        subtitle: 'Tunggu permohonan dari pelanggan',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: orders.length,
      itemBuilder: (_, i) => AnimatedFadeSlider(
        key: ValueKey(orders[i].id),
        index: i + 1,
        child: _AdminOrderCard(
          order: orders[i],
          statusColorFn: statusColorFn,
          onAccept: onAccept,
          onReject: onReject,
          onAdvance: onAdvance,
        ),
      ),
    );
  }
}

// ─── Admin Order Card ─────────────────────────────────────────

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;
  final OrderStatusColor Function(OrderStatus) statusColorFn;
  final void Function(OrderModel)? onAccept;
  final void Function(OrderModel)? onReject;
  final void Function(OrderModel)? onAdvance;

  const _AdminOrderCard({
    required this.order,
    required this.statusColorFn,
    this.onAccept,
    this.onReject,
    this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final sc = statusColorFn(order.status);

    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header (tap → detail sheet) ────
            GestureDetector(
              onTap: () => OrderDetailSheet.show(context, order),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.itemName.isNotEmpty
                                  ? order.itemName
                                  : order.id,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColor.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColor.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.category.label,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColor.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 95),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: sc.bgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(order.status.iconData, size: 14, color: sc.color),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  order.status.label,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: sc.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _infoChip(Icons.scale_outlined, order.quantityLabel),
                      _infoChip(
                        Icons.calendar_today_outlined,
                        '${DateFormat('d MMM yy', 'id').format(order.pickupDate)}${formatRelativeDate(order.pickupDate)}',
                      ),
                      if (order.estimatedTotal != null)
                        _infoChip(
                          Icons.payments_outlined,
                          order.discount > 0
                              ? '${formatRupiah(order.finalPrice)} (diskon -${formatRupiah(order.discount)})'
                              : NumberFormat.currency(
                                  locale: 'id',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(order.estimatedTotal),
                        ),
                    ],
                  ),
                  if (order.status == OrderStatus.rejected &&
                      order.rejectionReason != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.error.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Alasan: ${order.rejectionReason}',
                          style: const TextStyle(fontSize: 11, color: AppColor.error)),
                    ),
                  ],
                ],
              ),
            ),
            // ── Action buttons ─
            const SizedBox(height: 10),
            if (order.status == OrderStatus.request) ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton.icon(
                        onPressed: () => onReject?.call(order),
                        icon: const Icon(Icons.close, size: 14),
                        label: const Text('Tolak', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.error,
                          side: const BorderSide(color: AppColor.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () => onAccept?.call(order),
                        icon: const Icon(Icons.check, size: 14),
                        label: const Text('Terima', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (order.status == OrderStatus.accepted) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_empty, size: 14, color: AppColor.info),
                    SizedBox(width: 6),
                    Text(
                      'Menunggu persetujuan customer',
                      style: TextStyle(fontSize: 12, color: AppColor.info, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ] else if (orderNextStatus(order.status) != null) ...[
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: () => onAdvance?.call(order),
                  icon: Icon(orderAdvanceIcon(order.status), size: 14),
                  label: Text(
                    '➡️ ${orderNextStatus(order.status)!.label}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColor.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColor.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top-level helpers ────────────────────────────────────────

OrderStatus? orderNextStatus(OrderStatus current) {
  switch (current) {
    case OrderStatus.pickedUp:
      return OrderStatus.processing;
    case OrderStatus.processing:
      return OrderStatus.delivering;
    case OrderStatus.delivering:
      return OrderStatus.completed;
    default:
      return null;
  }
}

IconData orderAdvanceIcon(OrderStatus current) {
  switch (current) {
    case OrderStatus.pickedUp:
      return Icons.local_laundry_service_outlined;
    case OrderStatus.processing:
      return Icons.local_shipping_outlined;
    case OrderStatus.delivering:
      return Icons.check_circle_outline;
    default:
      return Icons.arrow_forward;
  }
}

class OrderStatusColor {
  final Color color;
  final Color bgColor;
  const OrderStatusColor(this.color, this.bgColor);
}

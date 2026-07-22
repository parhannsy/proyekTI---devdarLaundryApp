import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/providers/order_provider.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/core/providers/voucher_provider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/currency_formatter.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_bar.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/order_detail_sheet.dart';
import 'package:devdar_laundry_pos_app/core/router/app_router.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrderProvider>();
      // Daftar listener agar halaman update saat stream mengirim data baru
      provider.addListener(_onOrdersChanged);
      _syncOrders(provider);
      _startStream();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    // Hapus listener agar tidak memory leak
    try {
      context.read<OrderProvider>().removeListener(_onOrdersChanged);
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
    });
  }

  void _onTabChanged() {
    setState(() {});
  }

  void _startStream() {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user != null) {
      // Realtime stream — setiap perubahan dari Firestore/Mock langsung
      // mengupdate _orders via notifyListeners(), dan listener di atas
      // akan memanggil _syncOrders() untuk memperbarui UI
      context.read<OrderProvider>().listenCustomerOrders(user.id);
    }
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

  @override
  Widget build(BuildContext context) {
    final activeOrders = _orders.where((o) => o.status.isActive).toList();
    final failedOrders = _orders
        .where((o) =>
            o.status == OrderStatus.rejected ||
            o.status == OrderStatus.cancelled)
        .toList();
    final nonCompletedOrders = _orders
        .where((o) => o.status != OrderStatus.completed)
        .toList();

    return Scaffold(
      backgroundColor: AppColor.background,
      body: Column(
        children: [
          MinimalBar(
            title: 'Pesanan Saya',
            actions: [
              // ── History button ─────────────────────
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.customerHistory),
                  icon: const Icon(Icons.history_rounded, size: 16),
                  label: const Text(
                    'Riwayat',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primary,
                    side: const BorderSide(color: AppColor.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ── New Order button ───────────────────
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await context.push<bool>(
                      '/customer/orders/create',
                    );
                    if (result == true) {
                      // Stream sudah aktif — akan otomatis update
                      _syncOrders(context.read<OrderProvider>());
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Baru',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),
            ],
          ),

          // ── Tab bar ──────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColor.primary,
                unselectedLabelColor: AppColor.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'Aktif (${activeOrders.length})'),
                  Tab(text: 'Gagal (${failedOrders.length})'),
                  Tab(text: 'Semua (${nonCompletedOrders.length})'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),

          // ── Content ───────────────────────────
          Expanded(
            child: _isLoading && _orders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _OrderListView(
                        key: const ValueKey('cust_tab_active'),
                        orders: activeOrders,
                        emptyMsg: 'Tidak ada pesanan aktif',
                        statusColorFn: _statusColor,
                        showActions: true,
                        onCancel: (order) => _confirmCancel(context, order),
                        onAgree: (order) => _agreeToOrder(context, order),
                      ),
                      _OrderListView(
                        key: const ValueKey('cust_tab_failed'),
                        orders: failedOrders,
                        emptyMsg: 'Tidak ada pesanan gagal',
                        statusColorFn: _statusColor,
                        showActions: true,
                        onCancel: (order) => _confirmCancel(context, order),
                        onAgree: (order) => _agreeToOrder(context, order),
                      ),
                      _OrderListView(
                        key: const ValueKey('cust_tab_all'),
                        orders: nonCompletedOrders,
                        emptyMsg: 'Belum ada pesanan',
                        statusColorFn: _statusColor,
                        showActions: true,
                        onCancel: (order) => _confirmCancel(context, order),
                        onAgree: (order) => _agreeToOrder(context, order),
                      ),
                    ],
                  ),
          ),
        ],
      ),

    );
  }

  void _confirmCancel(
    BuildContext context,
    OrderModel order,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pesanan?'),
        content: Text('Pesanan ${order.id} akan dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () async {
              final orderProv = context.read<OrderProvider>();
              Navigator.pop(ctx);
              final success = await orderProv.cancelOrder(order.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? '✅ Pesanan dibatalkan'
                        : '❌ Gagal: ${orderProv.errorMessage ?? ""}'),
                    backgroundColor:
                        success ? AppColor.success : AppColor.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.error),
            child: const Text('Batalkan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _agreeToOrder(
    BuildContext context,
    OrderModel order,
  ) {
    final basePrice = order.estimatedTotal ?? 0;
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id;
    final vp = context.read<VoucherProvider>();

    vp.loadPublicVouchers().then((_) {
      if (userId == null) {
        _showAgreeSheet(context, order, basePrice, []);
        return;
      }
      vp.getClaimedVoucherIds(userId).then((claimedIds) {
        if (!mounted) return;
        final ids = claimedIds.toSet();
        final vouchers = vp.activeVouchers.where((v) => ids.contains(v.id)).toList();
        _showAgreeSheet(context, order, basePrice, vouchers);
      });
    });
  }

  void _showAgreeSheet(BuildContext context, OrderModel order, double basePrice, List<VoucherModel> vouchers) {
    VoucherModel? selectedVoucher;

    double calcDiscount(VoucherModel? v) {
      if (v == null || basePrice <= 0) return 0;
      switch (v.type) {
        case VoucherType.percentage:
          return basePrice * (v.value / 100);
        case VoucherType.fixed:
        case VoucherType.freeShipping:
          return v.value;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final discAmount = calcDiscount(selectedVoucher);
          final finalPrice = basePrice - discAmount;
          final hasDiscount = selectedVoucher != null && discAmount > 0;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.75,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (_, scrollCtrl) => ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  // ── Drag handle ──────────────────
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Header ───────────────────────
                  Text(
                    'Setujui Pesanan',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.itemName.isNotEmpty ? order.itemName : 'Pesanan'} — ${order.category.label}',
                    style: const TextStyle(fontSize: 13, color: AppColor.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // ── Price card ───────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColor.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Original price (with strikethrough if discount)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estimasi Biaya',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.textSecondary,
                              ),
                            ),
                            Text(
                              formatRupiah(basePrice),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textPrimary,
                                decoration: hasDiscount
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppColor.error,
                              ),
                            ),
                          ],
                        ),

                        // Discount row
                        if (hasDiscount) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.local_offer_rounded,
                                      size: 14, color: AppColor.error),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Diskon ${selectedVoucher!.code}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColor.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '-${formatRupiah(discAmount)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          // Final price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Dibayar',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.textPrimary,
                                ),
                              ),
                              Text(
                                formatRupiah(finalPrice),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Voucher picker ──────────────
                  Row(
                    children: [
                      const Icon(Icons.local_offer_outlined,
                          size: 16, color: AppColor.primary),
                      const SizedBox(width: 6),
                      Text(
                        hasDiscount ? 'Ganti Voucher' : 'Pakai Voucher Diskon',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (vouchers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline,
                              size: 14, color: AppColor.textMuted),
                          SizedBox(width: 6),
                          Text(
                            'Tidak ada voucher tersedia saat ini',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...vouchers.map((v) {
                      final isSelected = v.id == selectedVoucher?.id;
                      final (Color badgeColor, IconData badgeIcon) = _badgeForType(v.type);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setSheetState(() {
                              selectedVoucher =
                                  isSelected ? null : v;
                            }),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColor.primary.withValues(alpha: 0.06)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColor.primary.withValues(alpha: 0.4)
                                      : AppColor.divider,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Value badge
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: _buildVoucherValue(v, badgeColor),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v.code,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.textPrimary,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          v.title,
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
                                  // Checkmark
                                  if (isSelected)
                                    const Icon(Icons.check_circle_rounded,
                                        size: 20, color: AppColor.primary)
                                  else
                                    Icon(Icons.add_circle_outline,
                                        size: 20, color: AppColor.textMuted),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 20),

                  // ── Info text ────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.info.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: AppColor.info),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dengan menyetujui, pesanan akan lanjut ke tahap penjemputan.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColor.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Action buttons ───────────────
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Nanti',
                                style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              final orderProv = context.read<OrderProvider>();
                              Navigator.pop(ctx);
                              final success = await orderProv.agreeToOrder(
                                order.id,
                                discount: discAmount,
                                voucherCode: selectedVoucher?.code,
                              );
                              // Kurangi kuota pemakaian voucher jika pakai voucher
                              if (success && selectedVoucher != null) {
                                final auth = context.read<AuthProvider>();
                                final userId = auth.currentUser?.id;
                                if (userId != null) {
                                  context
                                      .read<VoucherProvider>()
                                      .redeemVoucher(selectedVoucher!.id, userId);
                                }
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success
                                        ? '✅ Pesanan dilanjutkan ke penjemputan!'
                                        : '❌ Gagal: ${orderProv.errorMessage ?? ""}'),
                                    backgroundColor:
                                        success ? AppColor.success : AppColor.error,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.success,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              hasDiscount
                                  ? 'Setuju ${formatRupiah(finalPrice)}'
                                  : 'Setuju',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Order List View ─────────────────────────────────────────

class _OrderListView extends StatelessWidget {
  final List<OrderModel> orders;
  final String emptyMsg;
  final OrderStatusColor Function(OrderStatus) statusColorFn;
  final bool showActions;
  final void Function(OrderModel)? onCancel;
  final void Function(OrderModel)? onAgree;

  const _OrderListView({
    super.key,
    required this.orders,
    required this.emptyMsg,
    required this.statusColorFn,
    this.showActions = false,
    this.onCancel,
    this.onAgree,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColor.textMuted),
            const SizedBox(height: 12),
            Text(emptyMsg,
                style: const TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 14,
                )),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: orders.length,
      itemBuilder: (_, i) {
        final order = orders[i];
        final sc = statusColorFn(order.status);
        return AnimatedFadeSlider(
          key: ValueKey(orders[i].id),
          index: i + 1,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildCard(context, order, sc),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, OrderModel order, OrderStatusColor sc) {
    return MinimalCard(
        radius: 12,
      withBorder: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header (tap → detail sheet) ──
          GestureDetector(
            onTap: () => OrderDetailSheet.show(context, order),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.itemName.isNotEmpty ? order.itemName : order.id.isNotEmpty ? order.id : 'Order Baru',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sc.bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: sc.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ── Item detail ───────────────────
          Text(
            '${order.category.label} • ${order.quantityLabel}',
            style: const TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
          if (order.status == OrderStatus.accepted &&
              order.estimatedTotal != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 14, color: AppColor.success),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      order.discount > 0
                          ? 'Estimasi: ${formatRupiah(order.estimatedTotal!)} (Diskon: -${formatRupiah(order.discount)})'
                          : 'Estimasi: ${formatRupiah(order.estimatedTotal!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColor.success,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Progress bar ──────────────────
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: order.status.progressValue,
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                sc.color.withValues(alpha: 0.8),
              ),
              minHeight: 4,
            ),
          ),
            ],
          ),
          ),

          // ── Action buttons (di luar tap detail) ─
          if (showActions && order.status == OrderStatus.accepted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => onCancel?.call(order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.error,
                        side: const BorderSide(color: AppColor.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Batalkan',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => onAgree?.call(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Setuju',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (showActions && order.status == OrderStatus.rejected &&
              order.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: AppColor.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.rejectionReason!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColor.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Helper data classes ──────────────────────────────────────

class OrderStatusColor {
  final Color color;
  final Color bgColor;
  const OrderStatusColor(this.color, this.bgColor);
}

// ─── Price breakdown helper ────────────────────────────────────
(Color, IconData) _badgeForType(VoucherType type) {
  switch (type) {
    case VoucherType.percentage:
      return (AppColor.primary, Icons.percent);
    case VoucherType.fixed:
      return (AppColor.success, Icons.monetization_on_outlined);
    case VoucherType.freeShipping:
      return (const Color(0xFF7B1FA2), Icons.local_shipping_outlined);
  }
}

/// Tampilan nilai voucher.
Widget _buildVoucherValue(VoucherModel voucher, Color color) {
  switch (voucher.type) {
    case VoucherType.percentage:
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            voucher.value.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.0,
            ),
          ),
          Text(
            '%',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.7),
              height: 1.0,
            ),
          ),
        ],
      );
    case VoucherType.fixed:
      return Text(
        'Rp${voucher.value.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
    case VoucherType.freeShipping:
      return Icon(Icons.local_shipping_outlined, size: 20, color: color);
  }
}



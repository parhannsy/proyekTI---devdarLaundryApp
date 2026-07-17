import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/providers/order_provider.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_bar.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/order_detail_sheet.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user != null) {
      context.read<OrderProvider>().loadCustomerOrders(user.id);
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
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          final activeOrders = provider.orders.where((o) => o.status.isActive).toList();
          final completedOrders = provider.orders
              .where((o) => !o.status.isActive)
              .toList();

          return Column(
            children: [
              const MinimalBar(title: 'Pesanan Saya'),

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
                      Tab(
                        text: 'Aktif (${activeOrders.length})',
                      ),
                      Tab(
                        text: 'Selesai (${completedOrders.length})',
                      ),
                      Tab(
                        text: 'Semua (${provider.orders.length})',
                      ),
                    ],
                  ),
                ),
              ),

              // ── Content ───────────────────────────
              Expanded(
                child: provider.isLoading && provider.orders.isEmpty
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
                            onCancel: (order) =>
                                _confirmCancel(context, order, provider),
                            onAgree: (order) =>
                                _agreeToOrder(context, order, provider),
                          ),
                          _OrderListView(
                            key: const ValueKey('cust_tab_completed'),
                            orders: completedOrders,
                            emptyMsg: 'Belum ada pesanan selesai',
                            statusColorFn: _statusColor,
                          ),
                          _OrderListView(
                            key: const ValueKey('cust_tab_all'),
                            orders: provider.orders,
                            emptyMsg: 'Belum ada pesanan',
                            statusColorFn: _statusColor,
                            showActions: true,
                            onCancel: (order) =>
                                _confirmCancel(context, order, provider),
                            onAgree: (order) =>
                                _agreeToOrder(context, order, provider),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<bool>(
            '/customer/orders/create',
          );
          if (result == true) _loadOrders();
        },
        backgroundColor: AppColor.primary,
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          'Order Baru',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _confirmCancel(
    BuildContext context,
    OrderModel order,
    OrderProvider provider,
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
              Navigator.pop(ctx);
              final success = await provider.cancelOrder(order.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? '✅ Pesanan dibatalkan'
                        : '❌ Gagal: ${provider.errorMessage ?? ""}'),
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
    OrderProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Setuju dengan Biaya?'),
        content: Text(
          'Estimasi biaya: Rp ${order.estimatedTotal?.toStringAsFixed(0) ?? '?'}\n\n'
          'Dengan menyetujui, pesanan akan lanjut ke tahap penjemputan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.agreeToOrder(order.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? '✅ Pesanan dilanjutkan ke penjemputan!'
                        : '❌ Gagal: ${provider.errorMessage ?? ""}'),
                    backgroundColor:
                        success ? AppColor.success : AppColor.error,
                  ),
                );
              }
            },
            child: const Text('Setuju'),
          ),
        ],
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
                  Text(
                    'Estimasi: Rp ${order.estimatedTotal!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColor.success,
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

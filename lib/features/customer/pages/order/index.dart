import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_bar.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/dashboard/widgets/element_order_list.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Column(
        children: [
          const MinimalBar(title: 'Pesanan Saya'),
          // Tab bar minimalis
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
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Aktif'),
                  Tab(text: 'Selesai'),
                  Tab(text: 'Semua'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrderList(orders: _activeOrders),
                _OrderList(orders: _completedOrders),
                _OrderList(orders: _allOrders),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColor.primary,
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text('Order Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  static const _activeOrders = [
    _OrderEntry(orderId: 'ORD-2024-042', item: 'Paket Reguler', quantity: '3.5 kg', status: 'Dicuci', statusColor: AppColor.info, progress: 0.4),
    _OrderEntry(orderId: 'ORD-2024-041', item: 'Karpet', quantity: '2 pcs', status: 'Diterima', statusColor: AppColor.success, progress: 0.2),
  ];

  static const _completedOrders = [
    _OrderEntry(orderId: 'ORD-2024-039', item: 'Sepatu', quantity: '3 pcs', status: 'Selesai', statusColor: AppColor.success, progress: 1.0),
    _OrderEntry(orderId: 'ORD-2024-038', item: 'Dry Clean', quantity: '2 pcs', status: 'Selesai', statusColor: AppColor.success, progress: 1.0),
  ];

  static const _allOrders = [
    _OrderEntry(orderId: 'ORD-2024-042', item: 'Paket Reguler', quantity: '3.5 kg', status: 'Dicuci', statusColor: AppColor.info, progress: 0.4),
    _OrderEntry(orderId: 'ORD-2024-041', item: 'Karpet', quantity: '2 pcs', status: 'Diterima', statusColor: AppColor.success, progress: 0.2),
    _OrderEntry(orderId: 'ORD-2024-039', item: 'Sepatu', quantity: '3 pcs', status: 'Selesai', statusColor: AppColor.success, progress: 1.0),
    _OrderEntry(orderId: 'ORD-2024-038', item: 'Dry Clean', quantity: '2 pcs', status: 'Selesai', statusColor: AppColor.success, progress: 1.0),
  ];
}

class _OrderList extends StatelessWidget {
  final List<_OrderEntry> orders;
  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColor.textMuted),
            SizedBox(height: 12),
            Text('Tidak ada pesanan', style: TextStyle(color: AppColor.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: orders.length,
      itemBuilder: (_, i) => AnimatedFadeSlider(
        index: i + 1,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OrderCard(
            orderId: orders[i].orderId,
            item: orders[i].item,
            quantity: orders[i].quantity,
            status: orders[i].status,
            statusColor: orders[i].statusColor,
            progress: orders[i].progress,
          ),
        ),
      ),
    );
  }
}

class _OrderEntry {
  final String orderId, item, quantity, status;
  final Color statusColor;
  final double progress;
  const _OrderEntry({required this.orderId, required this.item, required this.quantity, required this.status, required this.statusColor, required this.progress});
}

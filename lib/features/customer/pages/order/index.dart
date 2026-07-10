import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/dashboard/widgets/element_order_list.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Selesai'),
            Tab(text: 'Semua'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrderList(orders: _activeOrders),
          _OrderList(orders: _completedOrders),
          _OrderList(orders: _allOrders),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColor.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Order Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static const _activeOrders = [
    _OrderEntry(
      orderId: 'ORD-2024-042',
      item: 'Paket Reguler',
      quantity: '3.5 kg',
      status: 'Dicuci',
      statusColor: AppColor.info,
      progress: 0.4,
    ),
    _OrderEntry(
      orderId: 'ORD-2024-041',
      item: 'Karpet',
      quantity: '2 pcs',
      status: 'Diterima',
      statusColor: AppColor.success,
      progress: 0.2,
    ),
  ];

  static const _completedOrders = [
    _OrderEntry(
      orderId: 'ORD-2024-039',
      item: 'Sepatu',
      quantity: '3 pcs',
      status: 'Selesai',
      statusColor: AppColor.success,
      progress: 1.0,
    ),
    _OrderEntry(
      orderId: 'ORD-2024-038',
      item: 'Dry Clean',
      quantity: '2 pcs',
      status: 'Selesai',
      statusColor: AppColor.success,
      progress: 1.0,
    ),
  ];

  static const _allOrders = [
    _OrderEntry(
      orderId: 'ORD-2024-042',
      item: 'Paket Reguler',
      quantity: '3.5 kg',
      status: 'Dicuci',
      statusColor: AppColor.info,
      progress: 0.4,
    ),
    _OrderEntry(
      orderId: 'ORD-2024-041',
      item: 'Karpet',
      quantity: '2 pcs',
      status: 'Diterima',
      statusColor: AppColor.success,
      progress: 0.2,
    ),
    _OrderEntry(
      orderId: 'ORD-2024-039',
      item: 'Sepatu',
      quantity: '3 pcs',
      status: 'Selesai',
      statusColor: AppColor.success,
      progress: 1.0,
    ),
    _OrderEntry(
      orderId: 'ORD-2024-038',
      item: 'Dry Clean',
      quantity: '2 pcs',
      status: 'Selesai',
      statusColor: AppColor.success,
      progress: 1.0,
    ),
  ];
}

/// Extracted widget agar AnimatedFadeSlider bisa di-reset
/// saat TabBarView bertukar tab (karena widget tree baru dibuat).
class _OrderList extends StatelessWidget {
  final List<_OrderEntry> orders;
  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada pesanan',
          style: TextStyle(color: AppColor.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: orders.length,
      itemBuilder: (_, i) => AnimatedFadeSlider(
        index: i + 1,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
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

  const _OrderEntry({
    required this.orderId,
    required this.item,
    required this.quantity,
    required this.status,
    required this.statusColor,
    required this.progress,
  });
}

import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/data/model/order/history.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String _activeFilter = 'Semua';

  final List<OrderHistory> _allOrders = [
    const OrderHistory(
      orderId: 'ORD-2024-043',
      serviceName: 'Pakaian',
      quantity: 3.5,
      unit: 'kg',
      date: '28 Des 2024',
      totalPrice: 24500,
      status: 'Proses',
    ),
    const OrderHistory(
      orderId: 'ORD-2024-042',
      serviceName: 'Sepatu',
      quantity: 1,
      unit: 'pasang',
      date: '27 Des 2024',
      totalPrice: 25000,
      status: 'Selesai',
    ),
    const OrderHistory(
      orderId: 'ORD-2024-041',
      serviceName: 'Selimut',
      quantity: 2,
      unit: 'pcs',
      date: '25 Des 2024',
      totalPrice: 40000,
      status: 'Diambil',
    ),
    const OrderHistory(
      orderId: 'ORD-2024-040',
      serviceName: 'Pakaian',
      quantity: 5,
      unit: 'kg',
      date: '22 Des 2024',
      totalPrice: 35000,
      status: 'Selesai',
    ),
    const OrderHistory(
      orderId: 'ORD-2024-039',
      serviceName: 'Karpet',
      quantity: 3,
      unit: 'm²',
      date: '20 Des 2024',
      totalPrice: 30000,
      status: 'Ditolak',
    ),
  ];

  List<OrderHistory> get _filteredOrders {
    if (_activeFilter == 'Semua') return _allOrders;

    if (_activeFilter == 'Aktif') {
      return _allOrders
          .where((o) => o.status.toLowerCase() == 'proses')
          .toList();
    }

    if (_activeFilter == 'Selesai') {
      return _allOrders
          .where((o) =>
              o.status.toLowerCase() == 'selesai' ||
              o.status.toLowerCase() == 'diambil')
          .toList();
    }

    return _allOrders;
  }

  String _formatPrice(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      primary: true,
      slivers: [
        Builder(
          builder: (context) => SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
        ),

        SliverList(
          delegate: SliverChildListDelegate([
            
            /// FILTER SECTION (SUDAH ADA BACKGROUND)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildFilterButton('Aktif')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFilterButton('Selesai')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFilterButton('Semua')),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// LIST ORDER
            ...List.generate(_filteredOrders.length, (index) {
              final order = _filteredOrders[index];

              final displayQty = order.quantity % 1 == 0
                  ? order.quantity.toInt().toString()
                  : order.quantity.toString();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedFadeSlider(
                  index: index + 1,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.orderId,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: order.getStatusBgColor(),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: order.getStatusTextColor(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${order.serviceName} • $displayQty ${order.unit} • ${order.date}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColor.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${_formatPrice(order.totalPrice)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 150),
          ]),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label) {
    final isActive = _activeFilter == label;

    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: () => setState(() => _activeFilter = label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isActive
              ? AppColor.primary
              : const Color(0xFFEBF3FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive
                ? Colors.white
                : const Color(0xFF5584C2),
          ),
        ),
      ),
    );
  }
}
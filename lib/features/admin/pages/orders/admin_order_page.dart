import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_page_header.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_empty_state.dart';

class AdminOrderPage extends StatefulWidget {
  const AdminOrderPage({super.key});

  @override
  State<AdminOrderPage> createState() => _AdminOrderPageState();
}

class _AdminOrderPageState extends State<AdminOrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  static const _statuses = ['Semua', 'Menunggu', 'Diproses', 'Siap', 'Selesai'];

  static final _orders = [
    _AdminOrder(
      id: 'ORD-2024-042',
      customer: 'Ahmad Farhan',
      type: 'Reguler',
      detail: '3.5 kg',
      status: 'Dicuci',
      statusColor: AppColor.info,
      date: '7 Jul 2026',
      total: 'Rp 35.000',
    ),
    _AdminOrder(
      id: 'ORD-2024-041',
      customer: 'Ahmad Farhan',
      type: 'Karpet',
      detail: '2 pcs',
      status: 'Diterima',
      statusColor: AppColor.warning,
      date: '7 Jul 2026',
      total: 'Rp 80.000',
    ),
    _AdminOrder(
      id: 'ORD-2024-040',
      customer: 'Siti Rahayu',
      type: 'Express',
      detail: '2 kg',
      status: 'Siap',
      statusColor: AppColor.success,
      date: '6 Jul 2026',
      total: 'Rp 32.000',
    ),
    _AdminOrder(
      id: 'ORD-2024-039',
      customer: 'Budi Santoso',
      type: 'Sepatu',
      detail: '3 pcs',
      status: 'Selesai',
      statusColor: AppColor.primary,
      date: '5 Jul 2026',
      total: 'Rp 75.000',
    ),
    _AdminOrder(
      id: 'ORD-2024-038',
      customer: 'Siti Rahayu',
      type: 'Dry Clean',
      detail: '2 pcs',
      status: 'Selesai',
      statusColor: AppColor.primary,
      date: '4 Jul 2026',
      total: 'Rp 90.000',
    ),
    _AdminOrder(
      id: 'ORD-2024-037',
      customer: 'Dewi Kusuma',
      type: 'Reguler',
      detail: '4 kg',
      status: 'Disetrika',
      statusColor: AppColor.primaryLight,
      date: '7 Jul 2026',
      total: 'Rp 40.000',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_AdminOrder> get _filtered {
    return _orders.where((o) {
      final q = _searchQuery.toLowerCase();
      return o.id.toLowerCase().contains(q) ||
          o.customer.toLowerCase().contains(q) ||
          o.type.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          AnimatedFadeSlider(
            index: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: AdminPageHeader(
                title: 'Kelola Pesanan',
                subtitle: '${_orders.length} total pesanan',
                actions: [
                  ElevatedButton.icon(
                    onPressed: () => _showCreateOrderDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text(
                      'Order Baru',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Search bar ───────────────────────────────────────
          AnimatedFadeSlider(
            index: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Cari ID, nama, atau jenis...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColor.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: AppColor.iconSecondary,
                  ),
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
          ),

          // ── Tab bar ──────────────────────────────────────────
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
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                tabAlignment: TabAlignment.start,
                tabs: _statuses.map((s) => Tab(text: s)).toList(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── List ─────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _statuses.map((s) => _buildOrderList(s)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status) {
    var list = _filtered;
    if (status != 'Semua') {
      list = list.where((o) {
        if (status == 'Diproses') {
          return [
            'Dicuci',
            'Dikeringkan',
            'Disetrika',
            'Diterima',
          ].contains(o.status);
        }
        return o.status == status;
      }).toList();
    }

    if (list.isEmpty) {
      return AdminEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Belum ada pesanan',
        subtitle: status == 'Semua'
            ? 'Buat order baru untuk pelanggan'
            : 'Tidak ada pesanan dengan status "$status"',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: list.length,
      itemBuilder: (_, i) => AnimatedFadeSlider(
        index: i + 1,
        child: _OrderCard(
          order: list[i],
          onUpdateStatus: () => _showUpdateStatusDialog(context, list[i]),
          onDelete: () => _confirmDelete(context, list[i]),
        ),
      ),
    );
  }

  void _showCreateOrderDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const _CreateOrderDialog());
  }

  void _showUpdateStatusDialog(BuildContext context, _AdminOrder order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _UpdateStatusSheet(order: order),
    );
  }

  void _confirmDelete(BuildContext context, _AdminOrder order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Order?'),
        content: Text('Order ${order.id} akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${order.id} berhasil dihapus'),
                  backgroundColor: AppColor.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.error),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Order Card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final _AdminOrder order;
  final VoidCallback onUpdateStatus;
  final VoidCallback onDelete;

  const _OrderCard({
    required this.order,
    required this.onUpdateStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.customer} • ${order.type} (${order.detail})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 11,
                    color: order.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: AppColor.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                order.date,
                style: const TextStyle(fontSize: 11, color: AppColor.textMuted),
              ),
              const Spacer(),
              Text(
                order.total,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onUpdateStatus,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: AppColor.primary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColor.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 14,
                    color: AppColor.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Update Status Sheet ──────────────────────────────────────────────────────

class _UpdateStatusSheet extends StatelessWidget {
  final _AdminOrder order;
  const _UpdateStatusSheet({required this.order});

  static const _nextStatuses = [
    'Dicuci',
    'Dikeringkan',
    'Disetrika',
    'Siap',
    'Selesai',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update Status: ${order.id}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Status saat ini: ${order.status}',
            style: const TextStyle(color: AppColor.textSecondary, fontSize: 13),
          ),
          const Divider(height: 20),
          ..._nextStatuses.map(
            (s) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                order.status == s
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: order.status == s
                    ? AppColor.primary
                    : AppColor.iconSecondary,
                size: 20,
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Status diubah ke "$s"'),
                    backgroundColor: AppColor.success,
                  ),
                );
              },
              title: Text(s, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Create Order Dialog ──────────────────────────────────────────────────────

class _CreateOrderDialog extends StatelessWidget {
  const _CreateOrderDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat Order Baru',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _dialogField('Nama Pelanggan', Icons.person_outline),
            const SizedBox(height: 12),
            _dialogField('Jenis Layanan', Icons.local_laundry_service_outlined),
            const SizedBox(height: 12),
            _dialogField('Berat / Jumlah', Icons.scale_outlined),
            const SizedBox(height: 12),
            _dialogField('Catatan (opsional)', Icons.notes_outlined),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order berhasil dibuat'),
                          backgroundColor: AppColor.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColor.iconSecondary),
        filled: true,
        fillColor: AppColor.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

class _AdminOrder {
  final String id, customer, type, detail, status, date, total;
  final Color statusColor;
  const _AdminOrder({
    required this.id,
    required this.customer,
    required this.type,
    required this.detail,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.total,
  });
}

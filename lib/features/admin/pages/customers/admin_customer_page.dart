import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/mini_stat_card.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_page_header.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_empty_state.dart';

class AdminCustomerPage extends StatefulWidget {
  const AdminCustomerPage({super.key});

  @override
  State<AdminCustomerPage> createState() => _AdminCustomerPageState();
}

class _AdminCustomerPageState extends State<AdminCustomerPage> {
  String _searchQuery = '';

  final _customers = [
    _CustomerData(
      id: 'cust-001',
      name: 'Ahmad Farhan',
      email: 'customer@devdara.com',
      phone: '081234567890',
      points: 320,
      totalSavings: 'Rp 125.000',
      orderCount: 14,
      joinDate: '15 Jan 2024',
      tier: 'Gold',
    ),
    _CustomerData(
      id: 'cust-002',
      name: 'Siti Rahayu',
      email: 'siti.rahayu@gmail.com',
      phone: '082198765432',
      points: 150,
      totalSavings: 'Rp 65.000',
      orderCount: 7,
      joinDate: '10 Mar 2024',
      tier: 'Silver',
    ),
    _CustomerData(
      id: 'cust-003',
      name: 'Budi Santoso',
      email: 'budi.s@yahoo.com',
      phone: '085311223344',
      points: 75,
      totalSavings: 'Rp 30.000',
      orderCount: 4,
      joinDate: '22 Mei 2024',
      tier: 'Bronze',
    ),
    _CustomerData(
      id: 'cust-004',
      name: 'Dewi Kusuma',
      email: 'dewi.kusuma@email.com',
      phone: '087845678901',
      points: 210,
      totalSavings: 'Rp 87.500',
      orderCount: 11,
      joinDate: '8 Feb 2024',
      tier: 'Gold',
    ),
    _CustomerData(
      id: 'cust-005',
      name: 'Reza Pratama',
      email: 'reza.p@gmail.com',
      phone: '081567890123',
      points: 45,
      totalSavings: 'Rp 15.000',
      orderCount: 2,
      joinDate: '30 Jun 2024',
      tier: 'Bronze',
    ),
  ];

  List<_CustomerData> get _filtered {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return _customers;
    return _customers
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.email.toLowerCase().contains(q) ||
              c.phone.contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          AnimatedFadeSlider(
            index: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: AdminPageHeader(
                title: 'Pelanggan',
                subtitle: '${_customers.length} pelanggan terdaftar',
              ),
            ),
          ),
          AnimatedFadeSlider(
            index: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  MiniStatCard(
                    label: 'Total',
                    value: '${_customers.length}',
                    icon: Icons.people_outline,
                    color: AppColor.primary,
                  ),
                  const SizedBox(width: 10),
                  MiniStatCard(
                    label: 'Gold',
                    value:
                        '${_customers.where((c) => c.tier == "Gold").length}',
                    icon: Icons.star_rounded,
                    color: const Color(0xFFFFD700),
                  ),
                  const SizedBox(width: 10),
                  MiniStatCard(
                    label: 'Silver',
                    value:
                        '${_customers.where((c) => c.tier == "Silver").length}',
                    icon: Icons.star_half_rounded,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  MiniStatCard(
                    label: 'Bronze',
                    value:
                        '${_customers.where((c) => c.tier == "Bronze").length}',
                    icon: Icons.star_border_rounded,
                    color: const Color(0xFFCD7F32),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedFadeSlider(
            index: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Cari nama, email, atau nomor HP...',
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
          const SizedBox(height: 12),
          Expanded(
            child: _filtered.isEmpty
                ? const AdminEmptyState(
                    icon: Icons.people_outline,
                    title: 'Pelanggan tidak ditemukan',
                    subtitle: 'Coba kata kunci yang berbeda',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => AnimatedFadeSlider(
                      index: i + 1,
                      child: _CustomerCard(
                        customer: _filtered[i],
                        onDetail: () =>
                            _showCustomerDetail(context, _filtered[i]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetail(BuildContext context, _CustomerData c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CustomerDetailSheet(customer: c),
    );
  }
}

// ─── Customer Card ────────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  final _CustomerData customer;
  final VoidCallback onDetail;

  const _CustomerCard({required this.customer, required this.onDetail});

  Color get _tierColor {
    switch (customer.tier) {
      case 'Gold':
        return const Color(0xFFFFD700);
      case 'Silver':
        return Colors.grey;
      default:
        return const Color(0xFFCD7F32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDetail,
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColor.primary.withValues(alpha: 0.1),
              child: Text(
                customer.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _tierColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          customer.tier,
                          style: TextStyle(
                            fontSize: 10,
                            color: _tierColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    customer.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  Text(
                    '${customer.phone} • ${customer.orderCount}x order',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColor.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColor.warning,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${customer.points}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColor.warning,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'poin',
                  style: TextStyle(fontSize: 10, color: AppColor.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Customer Detail Sheet ────────────────────────────────────────────────────

class _CustomerDetailSheet extends StatelessWidget {
  final _CustomerData customer;
  const _CustomerDetailSheet({required this.customer});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColor.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColor.primary.withValues(alpha: 0.1),
                child: Text(
                  customer.name.substring(0, 1),
                  style: const TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Bergabung ${customer.joinDate}',
                    style: const TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          _row(Icons.email_outlined, 'Email', customer.email),
          _row(Icons.phone_outlined, 'Telepon', customer.phone),
          _row(Icons.star_rounded, 'Poin', '${customer.points} poin'),
          _row(Icons.savings_outlined, 'Total Hemat', customer.totalSavings),
          _row(
            Icons.inventory_2_outlined,
            'Jumlah Order',
            '${customer.orderCount}x',
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Tutup'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColor.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColor.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

class _CustomerData {
  final String id, name, email, phone, totalSavings, joinDate, tier;
  final int points, orderCount;

  const _CustomerData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.points,
    required this.totalSavings,
    required this.orderCount,
    required this.joinDate,
    required this.tier,
  });
}

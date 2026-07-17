import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_page_header.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_empty_state.dart';

class AdminVoucherPage extends StatefulWidget {
  const AdminVoucherPage({super.key});

  @override
  State<AdminVoucherPage> createState() => _AdminVoucherPageState();
}

class _AdminVoucherPageState extends State<AdminVoucherPage> {
  String _filter = 'Semua';

  final _vouchers = [
    _VoucherData(
      id: 'v-001',
      code: 'WELCOME20',
      title: 'Diskon 20% Order Pertama',
      description: 'Khusus pelanggan baru',
      type: 'Persen',
      value: '20%',
      quota: 100,
      used: 43,
      validUntil: '31 Des 2025',
      status: 'Aktif',
      statusColor: AppColor.success,
    ),
    _VoucherData(
      id: 'v-002',
      code: 'ONGKIRFREE',
      title: 'Gratis Ongkir s/d 5km',
      description: 'Berlaku semua layanan',
      type: 'Gratis Ongkir',
      value: 'Rp 15.000',
      quota: 200,
      used: 87,
      validUntil: '31 Agt 2025',
      status: 'Aktif',
      statusColor: AppColor.success,
    ),
    _VoucherData(
      id: 'v-003',
      code: 'SEPATU10K',
      title: 'Gratis Cuci Sepatu',
      description: 'Min. order 5kg',
      type: 'Nominal',
      value: 'Rp 25.000',
      quota: 50,
      used: 50,
      validUntil: '31 Mei 2024',
      status: 'Kedaluwarsa',
      statusColor: AppColor.error,
    ),
    _VoucherData(
      id: 'v-004',
      code: 'LOYAL15',
      title: 'Diskon Loyalitas 15%',
      description: 'Untuk pelanggan setia 10x order',
      type: 'Persen',
      value: '15%',
      quota: 30,
      used: 12,
      validUntil: '31 Jul 2025',
      status: 'Non-Publik',
      statusColor: AppColor.warning,
    ),
  ];

  List<_VoucherData> get _filtered {
    if (_filter == 'Semua') return _vouchers;
    return _vouchers.where((v) => v.status == _filter).toList();
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
                title: 'Kelola Voucher',
                subtitle: '${_vouchers.length} voucher terdaftar',
                actions: [
                  ElevatedButton.icon(
                    onPressed: () => _showVoucherDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text(
                      'Buat Voucher',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Filter chips
          AnimatedFadeSlider(
            index: 2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['Semua', 'Aktif', 'Non-Publik', 'Kedaluwarsa']
                    .map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                          selectedColor: AppColor.primary.withValues(
                            alpha: 0.15,
                          ),
                          checkmarkColor: AppColor.primary,
                          labelStyle: TextStyle(
                            color: _filter == f
                                ? AppColor.primary
                                : AppColor.textSecondary,
                            fontWeight: _filter == f
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? const AdminEmptyState(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Belum ada voucher',
                    subtitle: 'Buat voucher baru untuk pelanggan',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => AnimatedFadeSlider(
                      index: i + 1,
                      child: _VoucherCard(
                        voucher: _filtered[i],
                        onEdit: () =>
                            _showVoucherDialog(context, voucher: _filtered[i]),
                        onDelete: () => _confirmDelete(context, _filtered[i]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showVoucherDialog(BuildContext context, {_VoucherData? voucher}) {
    showDialog(
      context: context,
      builder: (_) => _VoucherDialog(voucher: voucher),
    );
  }

  void _confirmDelete(BuildContext context, _VoucherData v) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Voucher?'),
        content: Text('Voucher "${v.code}" akan dihapus.'),
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
                  content: Text('Voucher ${v.code} dihapus'),
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

class _VoucherCard extends StatelessWidget {
  final _VoucherData voucher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VoucherCard({
    required this.voucher,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final usagePercent = voucher.quota > 0 ? voucher.used / voucher.quota : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header stripe + info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primary.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: AppColor.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              voucher.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColor.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: voucher.statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                voucher.status,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: voucher.statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        voucher.title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColor.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  voucher.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              children: [
                // Quota progress
                Row(
                  children: [
                    const Text(
                      'Kuota:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${voucher.used}/${voucher.quota} digunakan',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColor.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: usagePercent,
                    backgroundColor: AppColor.progressBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      usagePercent >= 1.0 ? AppColor.error : AppColor.primary,
                    ),
                    minHeight: 5,
                  ),
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
                    Flexible(
                      child: Text(
                        'Berlaku s/d ${voucher.validUntil}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColor.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColor.primary,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: AppColor.error,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherDialog extends StatelessWidget {
  final _VoucherData? voucher;
  const _VoucherDialog({this.voucher});

  @override
  Widget build(BuildContext context) {
    final isEdit = voucher != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Edit Voucher' : 'Buat Voucher Baru',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _field('Kode Voucher', Icons.tag, initial: voucher?.code),
            const SizedBox(height: 10),
            _field('Judul', Icons.title_outlined, initial: voucher?.title),
            const SizedBox(height: 10),
            _field(
              'Deskripsi',
              Icons.description_outlined,
              initial: voucher?.description,
            ),
            const SizedBox(height: 10),
            _field(
              'Nilai Diskon (%/Rp)',
              Icons.percent,
              initial: voucher?.value,
            ),
            const SizedBox(height: 10),
            _field(
              'Total Kuota',
              Icons.people_outline,
              initial: voucher != null ? '${voucher!.quota}' : null,
            ),
            const SizedBox(height: 10),
            _field(
              'Berlaku Hingga',
              Icons.calendar_today_outlined,
              initial: voucher?.validUntil,
            ),
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
                        SnackBar(
                          content: Text(
                            isEdit ? 'Voucher diperbarui' : 'Voucher dibuat',
                          ),
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

  Widget _field(String hint, IconData icon, {String? initial}) {
    return TextField(
      controller: initial != null ? TextEditingController(text: initial) : null,
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

class _VoucherData {
  final String id, code, title, description, type, value, validUntil, status;
  final int quota, used;
  final Color statusColor;

  const _VoucherData({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    required this.quota,
    required this.used,
    required this.validUntil,
    required this.status,
    required this.statusColor,
  });
}

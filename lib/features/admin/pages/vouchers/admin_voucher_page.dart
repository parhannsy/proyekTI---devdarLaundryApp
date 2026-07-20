import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/currency_formatter.dart';
import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/providers/voucher_provider.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_page_header.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_empty_state.dart';


class AdminVoucherPage extends StatefulWidget {
  const AdminVoucherPage({super.key});

  @override
  State<AdminVoucherPage> createState() => _AdminVoucherPageState();
}

class _AdminVoucherPageState extends State<AdminVoucherPage> {
  String _filter = 'Semua';


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoucherProvider>().loadAllVouchers();
    });
  }

  List<VoucherModel> _filtered(List<VoucherModel> vouchers) {
    if (_filter == 'Semua') return vouchers;
    switch (_filter) {
      case 'Aktif':
        return vouchers.where((v) => v.isAvailable && v.isPublic).toList();
      case 'Non-Publik':
        return vouchers.where((v) => !v.isPublic).toList();
      case 'Kedaluwarsa':
        return vouchers.where((v) => v.isExpired || v.status == VoucherStatus.expired).toList();
      default:
        return vouchers;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<VoucherProvider>(
        builder: (context, vp, _) {
          final vouchers = vp.vouchers;
          final filtered = _filtered(vouchers);

          return Column(
            children: [
              // ── Header + summary ──
              AnimatedFadeSlider(
                index: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: AdminPageHeader(
                    title: 'Kelola Voucher',
                    subtitle: vp.isLoading
                        ? 'Memuat data...'
                        : '${vouchers.length} voucher terdaftar',
                    actions: [
                      ElevatedButton.icon(
                        onPressed: () => _showVoucherDialog(context, vp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10,
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

              // ── Stats row ──
              if (vouchers.isNotEmpty)
                AnimatedFadeSlider(
                  index: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _miniStat(
                          'Total',
                          '${vouchers.length}',
                          AppColor.primary,
                          Icons.confirmation_number_outlined,
                        ),
                        const SizedBox(width: 8),
                        _miniStat(
                          'Aktif',
                          '${vouchers.where((v) => v.isAvailable).length}',
                          AppColor.success,
                          Icons.check_circle_outline,
                        ),
                        const SizedBox(width: 8),
                        _miniStat(
                          'Kadaluwarsa',
                          '${vouchers.where((v) => v.isExpired || v.status == VoucherStatus.expired).length}',
                          AppColor.error,
                          Icons.event_busy_outlined,
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Filter chips ──
              AnimatedFadeSlider(
                index: 3,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: ['Semua', 'Aktif', 'Non-Publik', 'Kedaluwarsa']
                        .map((f) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(f),
                                selected: _filter == f,
                                onSelected: (_) => setState(() => _filter = f),
                                selectedColor:
                                    AppColor.primary.withValues(alpha: 0.15),
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
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── List ──
              Expanded(
                child: vp.isLoading && vouchers.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? const AdminEmptyState(
                            icon: Icons.confirmation_number_outlined,
                            title: 'Belum ada voucher',
                            subtitle: 'Buat voucher baru untuk pelanggan',
                          )
                        : RefreshIndicator(
                            onRefresh: () => vp.loadAllVouchers(),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) => AnimatedFadeSlider(
                                index: i + 4,
                                child: _VoucherCard(
                                  voucher: filtered[i],
                                  onEdit: () => _showVoucherDialog(context, vp,
                                      voucher: filtered[i]),
                                  onDelete: () => _confirmDelete(
                                      context, vp, filtered[i]),
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── CRUD Dialogs ────────────────────────────────────────────

  void _showVoucherDialog(BuildContext context, VoucherProvider vp,
      {VoucherModel? voucher}) {
    showDialog(
      context: context,
      builder: (_) => _VoucherFormDialog(
        voucher: voucher,
        onSave: (v) async {
          final success = voucher == null
              ? await vp.createVoucher(v)
              : await vp.updateVoucher(v);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success
                    ? voucher == null
                        ? '✅ Voucher berhasil dibuat'
                        : '✅ Voucher berhasil diperbarui'
                    : '❌ Gagal: ${vp.errorMessage ?? ""}'),
                backgroundColor: success ? AppColor.success : AppColor.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoucherProvider vp, VoucherModel v) {
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
            onPressed: () async {
              Navigator.pop(context);
              await vp.deleteVoucher(v.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Voucher ${v.code} dihapus'),
                    backgroundColor: AppColor.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.error),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Voucher Card ─────────────────────────────────────────────

class _VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VoucherCard({
    required this.voucher,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasClaimLimit = voucher.claimLimit != null && voucher.claimLimit! > 0;
    final claimProgress = hasClaimLimit
        ? voucher.claimCount / voucher.claimLimit!
        : 0.0;
    final statusStr = voucher.isExpired || voucher.status == VoucherStatus.expired
        ? 'Kedaluwarsa'
        : !voucher.isPublic
            ? 'Non-Publik'
            : 'Aktif';
    final statusColor = voucher.isExpired || voucher.status == VoucherStatus.expired
        ? AppColor.error
        : !voucher.isPublic
            ? AppColor.warning
            : AppColor.success;

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
                  (_voucherColor()).withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (_voucherColor()).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    color: _voucherColor(),
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
                                horizontal: 6, vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusStr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: statusColor,
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
                  voucher.valueDisplay,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _voucherColor(),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              children: [
                // Tipe + Min Order
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        voucher.type.label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (voucher.minimumOrder != null) ...[
                      const SizedBox(width: 6),
                      Text(                          'Min. ${formatRupiah(voucher.minimumOrder!)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColor.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    Text(
                      voucher.isPublic ? 'Publik' : 'Private',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColor.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Sisa klaim (untuk admin — bukan kuota pemakaian)
                Row(
                  children: [
                    const Text(
                      'Sisa:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        hasClaimLimit
                            ? '${(voucher.claimLimit! - voucher.claimCount).clamp(0, voucher.claimLimit!)} customer yang bisa memiliki'
                            : 'Tanpa batas klaim',
                        style: TextStyle(
                          fontSize: 12,
                          color: hasClaimLimit
                              ? AppColor.textPrimary
                              : AppColor.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (hasClaimLimit) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: claimProgress,
                      backgroundColor: AppColor.progressBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        claimProgress >= 1.0 ? AppColor.error : AppColor.primary,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColor.textMuted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Berlaku s/d ${voucher.validUntil.day}/${voucher.validUntil.month}/${voucher.validUntil.year}',
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
                      icon: const Icon(Icons.edit_outlined,
                          size: 16, color: AppColor.primary),
                      constraints: const BoxConstraints(
                          minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline,
                          size: 16, color: AppColor.error),
                      constraints: const BoxConstraints(
                          minWidth: 32, minHeight: 32),
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

  Color _voucherColor() {
    switch (voucher.type) {
      case VoucherType.percentage:
        return AppColor.primary;
      case VoucherType.fixed:
        return AppColor.success;
      case VoucherType.freeShipping:
        return const Color(0xFF7B1FA2);
    }
  }
}

// ─── Voucher Form Dialog ─────────────────────────────────────

class _VoucherFormDialog extends StatefulWidget {
  final VoucherModel? voucher;
  final Function(VoucherModel) onSave;

  const _VoucherFormDialog({this.voucher, required this.onSave});

  @override
  State<_VoucherFormDialog> createState() => _VoucherFormDialogState();
}

class _VoucherFormDialogState extends State<_VoucherFormDialog> {
  late TextEditingController _codeCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _valueCtrl;
  late TextEditingController _minOrderCtrl;
  late TextEditingController _quotaCtrl;
  late TextEditingController _claimLimitCtrl;
  final _formKey = GlobalKey<FormState>();

  VoucherType _type = VoucherType.percentage;
  bool _isPublic = true;


  @override
  void initState() {
    super.initState();
    final v = widget.voucher;
    _codeCtrl = TextEditingController(text: v?.code ?? '');
    _titleCtrl = TextEditingController(text: v?.title ?? '');
    _descCtrl = TextEditingController(text: v?.description ?? '');
    _valueCtrl = TextEditingController(
        text: v != null ? v.value.toStringAsFixed(0) : '');
    _minOrderCtrl = TextEditingController(
        text: v?.minimumOrder != null
            ? v!.minimumOrder!.toStringAsFixed(0)
            : '');
    _quotaCtrl = TextEditingController(
        text: v != null ? v.totalQuota.toString() : '');
    _claimLimitCtrl = TextEditingController(
        text: v?.claimLimit != null ? v!.claimLimit.toString() : '');
    if (v != null) {
      _type = v.type;
      _isPublic = v.isPublic;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _valueCtrl.dispose();
    _minOrderCtrl.dispose();
    _quotaCtrl.dispose();
    _claimLimitCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final voucher = VoucherModel(
      id: widget.voucher?.id ?? 'new-${DateTime.now().millisecondsSinceEpoch}',
      code: _codeCtrl.text.trim().toUpperCase(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      type: _type,
      value: double.tryParse(_valueCtrl.text) ?? 0,
      minimumOrder: _minOrderCtrl.text.isEmpty
          ? null
          : double.tryParse(_minOrderCtrl.text),
      totalQuota: int.tryParse(_quotaCtrl.text) ?? 0,
      usedQuota: widget.voucher?.usedQuota ?? 0,
      claimCount: widget.voucher?.claimCount ?? 0,
      claimLimit: _claimLimitCtrl.text.isEmpty
          ? null
          : int.tryParse(_claimLimitCtrl.text),
      validFrom: widget.voucher?.validFrom ?? DateTime.now(),
      validUntil: DateTime(
        DateTime.now().year + 1,
        DateTime.now().month,
        DateTime.now().day,
      ),
      status: widget.voucher?.status ?? VoucherStatus.active,
      isPublic: _isPublic,
    );

    Navigator.pop(context);
    widget.onSave(voucher);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.voucher != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Voucher' : 'Buat Voucher Baru',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),

              // Kode
              TextFormField(
                controller: _codeCtrl,
                decoration: _input('Kode Voucher', Icons.tag),
                style: const TextStyle(
                    fontSize: 14,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Judul
              TextFormField(
                controller: _titleCtrl,
                decoration: _input('Judul', Icons.title_outlined),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Deskripsi
              TextFormField(
                controller: _descCtrl,
                decoration: _input('Deskripsi', Icons.description_outlined),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Tipe Diskon
              const Text('Tipe Diskon',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary)),
              const SizedBox(height: 6),
              SegmentedButton<VoucherType>(
                segments: VoucherType.values
                    .map((t) => ButtonSegment(value: t, label: Text(t.label, style: const TextStyle(fontSize: 11))))
                    .toList(),
                selected: {_type},
                onSelectionChanged: (v) => setState(() => _type = v.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColor.primary.withValues(alpha: 0.1),
                  selectedForegroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),

              // Nilai
              TextFormField(
                controller: _valueCtrl,
                decoration: _input(
                  _type == VoucherType.percentage ? 'Nilai (%)' : 'Nilai (Rp)',
                  Icons.percent,
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return '> 0';
                  if (_type == VoucherType.percentage && n > 100) {
                    return 'Maks 100%';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Minimal Order
              TextFormField(
                controller: _minOrderCtrl,
                decoration: _input(
                    'Min. Belanja (Rp, opsional)', Icons.shopping_cart_outlined),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Kuota
              TextFormField(
                controller: _quotaCtrl,
                decoration: _input('Total Kuota (pemakaian)', Icons.people_outline),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return '> 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Batas Klaim
              Text('Batas Klaim (opsional, siapa cepat dia dapat)',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _claimLimitCtrl,
                decoration: _input(
                    'Kosongkan jika tidak ada batas klaim', Icons.people_alt_outlined),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Visibility
              Row(
                children: [
                  const Text('Publik',
                      style: TextStyle(
                          fontSize: 14, color: AppColor.textPrimary)),
                  const Spacer(),
                  Switch.adaptive(
                    value: _isPublic,
                    onChanged: (v) => setState(() => _isPublic = v),
                    activeTrackColor: AppColor.primary,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Simpan',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: AppColor.iconSecondary),
      filled: true,
      fillColor: AppColor.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

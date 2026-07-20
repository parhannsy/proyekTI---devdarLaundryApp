import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/providers/order_provider.dart';
import 'package:devdar_laundry_pos_app/core/providers/voucher_provider.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _panjangCtrl = TextEditingController();
  final _lebarCtrl = TextEditingController();
  final _voucherCodeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  OrderCategory _selectedCategory = OrderCategory.pakaian;
  UnitType _selectedUnitType = UnitType.kiloan;
  bool _pickupToday = true;
  DateTime _pickupDate = DateTime.now();
  bool _isSubmitting = false;

  // Voucher / Diskon
  List<VoucherModel> _availableVouchers = [];
  VoucherModel? _selectedVoucher;

  static const _categories = OrderCategory.values;

  // Ikon & warna per kategori
  static final Map<OrderCategory, _CategoryMeta> _catMeta = {
    OrderCategory.pakaian: _CategoryMeta(
      Icons.checkroom_outlined,
      const Color(0xFF2196F3),
      const Color(0xFFE3F2FD),
    ),
    OrderCategory.carpet: _CategoryMeta(
      Icons.grid_view_rounded,
      const Color(0xFF9C27B0),
      const Color(0xFFF3E5F5),
    ),
    OrderCategory.shoes: _CategoryMeta(
      Icons.smartphone_outlined,
      const Color(0xFF4CAF50),
      const Color(0xFFE8F5E9),
    ),
    OrderCategory.perlengkapanKamar: _CategoryMeta(
      Icons.bed_outlined,
      const Color(0xFF607D8B),
      const Color(0xFFECEFF1),
    ),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVouchers();
    });
  }

  void _loadVouchers() {
    final vp = context.read<VoucherProvider>();
    vp.loadPublicVouchers().then((_) {
      if (mounted) {
        setState(() {
          _availableVouchers = vp.activeVouchers;
        });
      }
    });
  }

  @override
  void dispose() {
    _itemNameCtrl.dispose();
    _quantityCtrl.dispose();
    _panjangCtrl.dispose();
    _lebarCtrl.dispose();
    _voucherCodeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate.isAfter(now) ? _pickupDate : now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      helpText: 'Pilih tanggal pick up',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) {
      setState(() => _pickupDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final auth = context.read<AuthProvider>();
      final orderProv = context.read<OrderProvider>();
      final user = auth.currentUser;
      if (user == null) throw Exception('Silakan login terlebih dahulu.');

      double quantity;
      String? notes = _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim();

      if (_selectedCategory == OrderCategory.carpet) {
        final panjang = double.tryParse(_panjangCtrl.text) ?? 0;
        final lebar = double.tryParse(_lebarCtrl.text) ?? 0;
        if (panjang <= 0 || lebar <= 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Panjang dan lebar harus lebih dari 0'),
                backgroundColor: AppColor.error,
              ),
            );
          }
          return;
        }
        quantity = panjang * lebar;
        String fmt(double d) =>
            d == d.roundToDouble() ? d.toInt().toString() : d.toStringAsFixed(1);
        final ukuranStr = 'Ukuran: ${fmt(panjang)}m × ${fmt(lebar)}m';
        notes = notes != null ? '$ukuranStr. $notes' : ukuranStr;
      } else {
        quantity = double.tryParse(_quantityCtrl.text) ?? 0;
        if (quantity <= 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Jumlah harus lebih dari 0'),
                backgroundColor: AppColor.error,
              ),
            );
          }
          return;
        }
      }

      final order = OrderModel(
        id: '',
        customerId: user.id,
        customerName: user.name,
        customerAddress: user.address ?? '',
        category: _selectedCategory,
        itemName: _itemNameCtrl.text.trim(),
        unitType: _selectedUnitType,
        quantity: quantity,
        status: OrderStatus.request,
        pickupDate: _pickupToday ? DateTime.now() : _pickupDate,
        notes: notes,
        voucherCode: _selectedVoucher?.code,
        createdAt: DateTime.now(),
      );

      final created = await orderProv.createOrder(order);
      if (created != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Permohonan order berhasil dikirim!'),
            backgroundColor: AppColor.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString()}'),
            backgroundColor: AppColor.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, size: 22),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Order Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Alamat (dari akun) ────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.home_outlined,
                          size: 18, color: AppColor.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Alamat Pengambilan',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColor.textSecondary,
                              ),
                            ),
                            Text(
                              user?.address?.isNotEmpty == true
                                  ? user!.address!
                                  : 'Belum diisi — lengkapi di profil',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Pilih Kategori ────────────────────────
                const Text(
                  'Pilih Kategori',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final meta = _catMeta[cat]!;
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedCategory = cat;
                        if (cat == OrderCategory.carpet) {
                          _selectedUnitType = UnitType.meteran;
                        } else if (_selectedUnitType == UnitType.meteran) {
                          _selectedUnitType = UnitType.kiloan;
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? meta.bgColor : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? meta.color
                                : AppColor.divider,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(meta.icon,
                                size: 16, color: meta.color),
                            const SizedBox(width: 6),
                            Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? meta.color
                                    : AppColor.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // ── Nama Barang ───────────────────────────
                TextFormField(
                  controller: _itemNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Barang',
                    hintText: 'Contoh: Baju, Celana, Jaket',
                    prefixIcon: const Icon(Icons.inventory_2_outlined,
                        size: 20, color: AppColor.iconSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama barang wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // ── Tipe Satuan ───────────────────────────
                const Text(
                  'Tipe',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<UnitType>(
                  segments: UnitType.values.map((t) {
                    return ButtonSegment<UnitType>(
                      value: t,
                      label: Text(
                        t.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  selected: {_selectedUnitType},
                  onSelectionChanged: _selectedCategory == OrderCategory.carpet
                      ? null
                      : (v) => setState(() => _selectedUnitType = v.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor:
                        AppColor.primary.withValues(alpha: 0.1),
                    selectedForegroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (_selectedCategory == OrderCategory.carpet)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 12, color: AppColor.textMuted),
                        const SizedBox(width: 4),
                        const Text(
                          'Karpet dihitung berdasarkan luas (m²)',
                          style: TextStyle(
                              fontSize: 11, color: AppColor.textMuted),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // ── Jumlah / Ukuran ─────────────────────────
                if (_selectedCategory == OrderCategory.carpet) ...[
                  // Untuk karpet: Panjang × Lebar
                  const Text(
                    'Ukuran Karpet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _panjangCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Panjang (m)',
                            hintText: 'Contoh: 3',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Panjang wajib diisi';
                            }
                            final n = double.tryParse(v);
                            if (n == null || n <= 0) return '> 0';
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.close,
                            size: 16, color: AppColor.textMuted),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _lebarCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Lebar (m)',
                            hintText: 'Contoh: 2',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Lebar wajib diisi';
                            }
                            final n = double.tryParse(v);
                            if (n == null || n <= 0) return '> 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  TextFormField(
                    controller: _quantityCtrl,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Jumlah (${_selectedUnitType.shortLabel})',
                      hintText: 'Masukkan jumlah',
                      prefixIcon: const Icon(Icons.scale_outlined,
                          size: 20, color: AppColor.iconSecondary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Jumlah wajib diisi';
                      }
                      final num = double.tryParse(v);
                      if (num == null || num <= 0) {
                        return 'Jumlah harus lebih dari 0';
                      }
                      if (_selectedUnitType == UnitType.satuan &&
                          num != num.roundToDouble()) {
                        return 'Jumlah satuan harus bilangan bulat';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 20),

                // ── Tanggal Pick Up ───────────────────────
                const Text(
                  'Tanggal Pick Up',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Hari Ini', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.today_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Atur Tanggal', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.calendar_month_outlined, size: 16),
                    ),
                  ],
                  selected: {_pickupToday},
                  onSelectionChanged: (v) {
                    setState(() {
                      _pickupToday = v.first;
                      if (!_pickupToday) {
                        _pickupDate = DateTime.now().add(const Duration(days: 1));
                      }
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor:
                        AppColor.success.withValues(alpha: 0.1),
                    selectedForegroundColor: AppColor.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (!_pickupToday) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              size: 18, color: AppColor.primary),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'id')
                                .format(_pickupDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.edit_calendar_outlined,
                              size: 16, color: AppColor.iconSecondary),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // ── Catatan ───────────────────────────────
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Catatan (opsional)',
                    hintText: 'Contoh: pisahkan baju putih dan warna',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Icon(Icons.notes_outlined,
                          size: 20, color: AppColor.iconSecondary),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Voucher / Diskon ──────────────────────
                _buildVoucherSection(),
                const SizedBox(height: 16),

                // ── Tombol Submit ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Kirim Permohonan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.send_rounded, size: 18),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Voucher / Diskon Section ──────────────────────────────

  Widget _buildVoucherSection() {
    final hasDiscount = _selectedVoucher != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDiscount
              ? AppColor.primary.withValues(alpha: 0.3)
              : AppColor.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          InkWell(
            onTap: _availableVouchers.isNotEmpty
                ? () => _showVoucherPicker()
                : null,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasDiscount
                          ? AppColor.primary.withValues(alpha: 0.1)
                          : AppColor.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      hasDiscount
                          ? Icons.local_offer_rounded
                          : Icons.local_offer_outlined,
                      size: 18,
                      color: hasDiscount
                          ? AppColor.primary
                          : AppColor.iconSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasDiscount ? 'Diskon Terpakai' : 'Pakai Diskon / Voucher',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: hasDiscount
                                ? AppColor.primary
                                : AppColor.textPrimary,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${_selectedVoucher!.valueDisplay} • ${_selectedVoucher!.code}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColor.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else if (_availableVouchers.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${_availableVouchers.length} diskon tersedia — ketuk untuk pilih',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColor.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_availableVouchers.isNotEmpty)
                    Icon(
                      hasDiscount
                          ? Icons.check_circle_rounded
                          : Icons.chevron_right,
                      size: 20,
                      color: hasDiscount
                          ? AppColor.primary
                          : AppColor.textMuted,
                    ),
                ],
              ),
            ),
          ),

          // ── Selected voucher info ──
          if (hasDiscount) ...[
            const Divider(height: 1, indent: 14, endIndent: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedVoucher!.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColor.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVoucher = null;
                        _voucherCodeCtrl.clear();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColor.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close, size: 12, color: AppColor.error),
                          SizedBox(width: 3),
                          Text(
                            'Hapus',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColor.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  void _showVoucherPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _VoucherPickerSheet(
        vouchers: _availableVouchers,
        selectedId: _selectedVoucher?.id,
        onSelect: (v) {
          Navigator.pop(context);
          setState(() {
            _selectedVoucher = v;
            _voucherCodeCtrl.text = v.code;
          });
        },
      ),
    );
  }
}

// ─── Voucher Picker Bottom Sheet ──────────────────────────────

class _VoucherPickerSheet extends StatelessWidget {
  final List<VoucherModel> vouchers;
  final String? selectedId;
  final ValueChanged<VoucherModel> onSelect;

  const _VoucherPickerSheet({
    required this.vouchers,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pilih Diskon / Voucher',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${vouchers.length} diskon tersedia untukmu',
            style: const TextStyle(
              fontSize: 13,
              color: AppColor.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: vouchers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final v = vouchers[i];
                final isSelected = v.id == selectedId;
                return _VoucherPickerItem(
                  voucher: v,
                  isSelected: isSelected,
                  onTap: () => onSelect(v),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tidak pakai diskon'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherPickerItem extends StatelessWidget {
  final VoucherModel voucher;
  final bool isSelected;
  final VoidCallback onTap;

  const _VoucherPickerItem({
    required this.voucher,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (Color badgeColor, IconData badgeIcon) = _badgeForType(voucher.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primary.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColor.primary.withValues(alpha: 0.4)
                  : AppColor.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Value
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _buildValue(badgeColor),
                ),
              ),
              const SizedBox(width: 12),
              // Info
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
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textPrimary,
                              letterSpacing: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(badgeIcon,
                                  size: 10, color: badgeColor),
                              const SizedBox(width: 3),
                              Text(
                                voucher.type.label,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: badgeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      voucher.title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColor.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (voucher.minimumOrder != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Min. Rp ${voucher.minimumOrder!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColor.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    size: 20, color: AppColor.primary)
              else
                const Icon(Icons.add_circle_outline,
                    size: 20, color: AppColor.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValue(Color color) {
    switch (voucher.type) {
      case VoucherType.percentage:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              voucher.value.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.0,
              ),
            ),
            Text(
              '%',
              style: TextStyle(
                fontSize: 10,
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        );
      case VoucherType.freeShipping:
        return Icon(Icons.local_shipping_outlined, size: 22, color: color);
    }
  }

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
}

class _CategoryMeta {
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _CategoryMeta(this.icon, this.color, this.bgColor);
}

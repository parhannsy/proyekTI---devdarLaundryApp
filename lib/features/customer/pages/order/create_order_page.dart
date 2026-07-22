import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/providers/order_provider.dart';
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
  final _notesCtrl = TextEditingController();

  OrderCategory _selectedCategory = OrderCategory.pakaian;
  UnitType _selectedUnitType = UnitType.kiloan;
  bool _pickupToday = true;
  DateTime _pickupDate = DateTime.now();
  bool _isSubmitting = false;
  String _selectedAddress = '';
  bool _addressPickerInitialized = false;
  bool _popPrevented = false;
  final _pendingNewAddressCtrl = TextEditingController();
  bool _pendingSaveLocation = false;
  final _pendingLabelCtrl = TextEditingController();
  String _addressSearchQuery = '';

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
      final user = context.read<AuthProvider>().currentUser;
      if (user != null && !_addressPickerInitialized) {
        setState(() {
          _selectedAddress = user.address ?? '';
          _addressPickerInitialized = true;
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
    _notesCtrl.dispose();
    _pendingNewAddressCtrl.dispose();
    _pendingLabelCtrl.dispose();
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
        customerAddress: _selectedAddress.isNotEmpty
            ? _selectedAddress
            : user.address ?? '',
        category: _selectedCategory,
        itemName: _itemNameCtrl.text.trim(),
        unitType: _selectedUnitType,
        quantity: quantity,
        status: OrderStatus.request,
        pickupDate: _pickupToday ? DateTime.now() : _pickupDate,
        notes: notes,

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
        // Bypass PopScope — rebuild widget dulu, baru pop
        setState(() => _popPrevented = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context, true);
        });
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

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  size: 20, color: AppColor.warning),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Tinggalkan Halaman?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Anda tengah membuat pesanan baru, batalkan proses?',
          style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Lanjutkan',
                style: TextStyle(color: AppColor.primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return PopScope(
      canPop: _popPrevented,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _popPrevented) return;
        final shouldPop = await _showExitConfirmation();
        if (shouldPop && context.mounted) {
          setState(() => _popPrevented = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.pop(context);
          });
        }
      },
      child: Scaffold(
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

                // ── Alamat (clickable → bottom sheet) ──
                InkWell(
                  onTap: () => _showAddressPicker(context, user),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
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
                                _selectedAddress.isNotEmpty
                                    ? _selectedAddress
                                    : 'Belum diisi — ketuk untuk pilih',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded,
                            size: 20, color: AppColor.textMuted),
                      ],
                    ),
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
    ),
  );
  }

  void _showAddressPicker(BuildContext context, UserModel? user) {
    // Reset search
    _addressSearchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          // Filter alamat berdasarkan pencarian
          final filteredAddresses = user != null && user.addresses.isNotEmpty
              ? (_addressSearchQuery.isEmpty
                  ? user.addresses
                  : user.addresses.where((a) {
                      final q = _addressSearchQuery.toLowerCase();
                      return a.address.toLowerCase().contains(q) ||
                          (a.label?.toLowerCase().contains(q) ?? false);
                    }).toList())
              : <AddressModel>[];

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.92,
              maxChildSize: 1.0,
              minChildSize: 0.5,
              expand: false,
              builder: (_, scrollCtrl) => ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  // ── Drag handle ──
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

                  // ── Header ──
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 20, color: AppColor.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: const Text(
                          'Pilih Alamat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, size: 20),
                        color: AppColor.textMuted,
                        splashRadius: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Content scrollable ──
                  // Note: seluruh konten sudah di dalam ListView (scrollCtrl)
                          // ── Search bar ──
                          if (user != null && user.addresses.isNotEmpty) ...[
                            TextField(
                              onChanged: (v) => setSheetState(
                                  () => _addressSearchQuery = v),
                              decoration: InputDecoration(
                                hintText: 'Cari alamat atau label...',
                                hintStyle: const TextStyle(
                                    fontSize: 13, color: AppColor.textMuted),
                                prefixIcon: const Icon(Icons.search,
                                    size: 20, color: AppColor.iconSecondary),
                                filled: true,
                                fillColor: AppColor.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                            const SizedBox(height: 12),

                            if (filteredAddresses.isEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                child: const Center(
                                  child: Text(
                                    'Alamat tidak ditemukan',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.textMuted),
                                  ),
                                ),
                              ),
                            ] else ...[
                              const Text(
                                'Alamat Tersimpan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...filteredAddresses.map((addr) {
                                final isSelected =
                                    addr.address == _selectedAddress;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() =>
                                            _selectedAddress = addr.address);
                                        Navigator.pop(ctx);
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColor.primary
                                                  .withValues(alpha: 0.06)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColor.primary
                                                    .withValues(alpha: 0.4)
                                                : AppColor.divider,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColor.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                  Icons.home_outlined,
                                                  size: 18,
                                                  color: AppColor.primary),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (addr.label != null)
                                                    Text(
                                                      addr.label!,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColor
                                                            .textPrimary,
                                                      ),
                                                    ),
                                                  Text(
                                                    addr.address,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColor
                                                          .textSecondary,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (addr.isDefault)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColor.primary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Utama',
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      color: AppColor.primary,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              isSelected
                                                  ? Icons
                                                      .check_circle_rounded
                                                  : Icons
                                                      .radio_button_unchecked_rounded,
                                              size: 20,
                                              color: isSelected
                                                  ? AppColor.primary
                                                  : AppColor.textMuted,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                          ],

                          // ── Tambah alamat baru ──
                          const Text(
                            'Tambah Lokasi Baru',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pendingNewAddressCtrl,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Alamat lengkap',
                              hintText: 'Masukkan alamat penjemputan & pengiriman',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 24),
                                child: Icon(Icons.add_location_outlined,
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

                          // ── Simpan lokasi ──
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => setSheetState(() {
                              _pendingSaveLocation = !_pendingSaveLocation;
                              if (!_pendingSaveLocation) {
                                _pendingLabelCtrl.clear();
                              }
                            }),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    _pendingSaveLocation
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    size: 22,
                                    color: _pendingSaveLocation
                                        ? AppColor.primary
                                        : AppColor.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Simpan lokasi ini',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: _pendingSaveLocation
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: AppColor.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_pendingSaveLocation) ...[
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _pendingLabelCtrl,
                              decoration: InputDecoration(
                                labelText: 'Label lokasi',
                                hintText: 'Contoh: Rumah, Kantor, Sekolah',
                                prefixIcon: const Icon(Icons.label_outline,
                                    size: 20, color: AppColor.iconSecondary),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // ── Tombol pakai ──
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                final newAddr =
                                    _pendingNewAddressCtrl.text.trim();
                                if (newAddr.isEmpty) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Masukkan alamat terlebih dahulu'),
                                      backgroundColor: AppColor.error,
                                    ),
                                  );
                                  return;
                                }

                                // Simpan ke akun jika dicentang
                                if (_pendingSaveLocation && user != null) {
                                  final label =
                                      _pendingLabelCtrl.text.trim().isNotEmpty
                                          ? _pendingLabelCtrl.text.trim()
                                          : null;
                                  final newAddress = AddressModel(
                                    address: newAddr,
                                    label: label,
                                    isDefault: user.addresses.isEmpty,
                                  );
                                  final updatedAddresses = [
                                    ...user.addresses,
                                    newAddress,
                                  ];
                                  context
                                      .read<AuthProvider>()
                                      .updateProfile(
                                    addresses: updatedAddresses,
                                  );
                                }

                                setState(() => _selectedAddress = newAddr);
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Gunakan Alamat Ini',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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

class _CategoryMeta {
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _CategoryMeta(this.icon, this.color, this.bgColor);
}

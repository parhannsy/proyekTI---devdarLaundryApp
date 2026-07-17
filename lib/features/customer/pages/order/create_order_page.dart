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
  final _notesCtrl = TextEditingController();

  OrderCategory _selectedCategory = OrderCategory.regular;
  UnitType _selectedUnitType = UnitType.kiloan;
  bool _pickupToday = true;
  DateTime _pickupDate = DateTime.now();
  bool _isSubmitting = false;

  static const _categories = OrderCategory.values;

  // Ikon & warna per kategori
  static final Map<OrderCategory, _CategoryMeta> _catMeta = {
    OrderCategory.regular: _CategoryMeta(
      Icons.local_laundry_service_outlined,
      const Color(0xFF2196F3),
      const Color(0xFFE3F2FD),
    ),
    OrderCategory.express: _CategoryMeta(
      Icons.flash_on_outlined,
      const Color(0xFFFF9800),
      const Color(0xFFFFF3E0),
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
    OrderCategory.dryClean: _CategoryMeta(
      Icons.checkroom_outlined,
      const Color(0xFF607D8B),
      const Color(0xFFECEFF1),
    ),
  };

  @override
  void dispose() {
    _itemNameCtrl.dispose();
    _quantityCtrl.dispose();
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

      final quantity = double.tryParse(_quantityCtrl.text) ?? 0;
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
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
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
                      onTap: () => setState(() => _selectedCategory = cat),
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
                  onSelectionChanged: (v) =>
                      setState(() => _selectedUnitType = v.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor:
                        AppColor.primary.withValues(alpha: 0.1),
                    selectedForegroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Jumlah ────────────────────────────────
                TextFormField(
                  controller: _quantityCtrl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                    if (_selectedUnitType == UnitType.satuan && num != num.roundToDouble()) {
                      return 'Jumlah satuan harus bilangan bulat';
                    }
                    return null;
                  },
                ),
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
                const SizedBox(height: 24),

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
}

class _CategoryMeta {
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _CategoryMeta(this.icon, this.color, this.bgColor);
}

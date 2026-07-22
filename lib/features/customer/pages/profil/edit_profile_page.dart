import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/currency_formatter.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/mini_stat_card.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _nicknameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _newAddressCtrl;
  late TextEditingController _newLabelCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _showAddAddress = false;
  bool _saveAddress = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _nicknameCtrl = TextEditingController(text: user?.nickname ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _newAddressCtrl = TextEditingController();
    _newLabelCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    _phoneCtrl.dispose();
    _newAddressCtrl.dispose();
    _newLabelCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      final auth = context.read<AuthProvider>();
      List<AddressModel>? updatedAddresses;

      if (_showAddAddress && _newAddressCtrl.text.trim().isNotEmpty) {
        final user = auth.currentUser;
        if (user != null) {
          final label = _saveAddress && _newLabelCtrl.text.trim().isNotEmpty
              ? _newLabelCtrl.text.trim()
              : null;
          final newAddress = AddressModel(
            address: _newAddressCtrl.text.trim(),
            label: label,
            isDefault: user.addresses.isEmpty,
          );
          updatedAddresses = [...user.addresses, newAddress];
        }
      }

      await auth.updateProfile(
        name: _nameCtrl.text.trim(),
        nickname: _nicknameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        addresses: updatedAddresses,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil berhasil diperbarui'),
            backgroundColor: AppColor.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: AppColor.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.12),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
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
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Edit Profil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _isSaving ? null : _save,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.primary,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.primary,
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ),            // ── Content ──────────────────────────────
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  // ── Profile Card ────────────────────
                  AnimatedFadeSlider(
                    index: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColor.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (user?.name ?? 'P').isNotEmpty
                                    ? (user!.name[0]).toUpperCase()
                                    : 'P',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Pelanggan',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColor.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded,
                                    size: 14, color: Color(0xFFFF9800)),
                                SizedBox(width: 4),
                                Text(
                                  'Terverifikasi',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFF9800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Stats ───────────────────────────
                  if (user != null) ...[
                    AnimatedFadeSlider(
                      index: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: MiniStatCard(
                              label: 'Poin',
                              value: formatDecimal(user.loyaltyPoints),
                              icon: Icons.star_rounded,
                              color: AppColor.warning,
                              showIconBackground: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MiniStatCard(
                              label: 'Total Hemat',
                              value: formatRupiahCompact(user.totalSavings),
                              icon: Icons.savings_outlined,
                              color: AppColor.success,
                              showIconBackground: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MiniStatCard(
                              label: 'Alamat',
                              value: '${user.addresses.length}',
                              icon: Icons.home_outlined,
                              color: AppColor.primary,
                              showIconBackground: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Informasi Akun ──────────────────
                  const AnimatedFadeSlider(
                    index: 3,
                    child: _SectionLabel(label: 'Informasi Akun'),
                  ),
                  const SizedBox(height: 10),

                  AnimatedFadeSlider(
                    index: 4,
                    child: _EditableField(
                      label: 'Nama Lengkap',
                      icon: Icons.person_outline,
                      controller: _nameCtrl,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(height: 10),

                  AnimatedFadeSlider(
                    index: 5,
                    child: _EditableField(
                      label: 'Nama Panggilan',
                      icon: Icons.face_outlined,
                      controller: _nicknameCtrl,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(height: 10),

                  AnimatedFadeSlider(
                    index: 6,
                    child: _EditableField(
                      label: 'Nomor Telepon',
                      icon: Icons.phone_outlined,
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Wajib diisi';
                        }
                        if (v.trim().length < 10) {
                          return 'Minimal 10 digit';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Email (read-only) ───────────────
                  AnimatedFadeSlider(
                    index: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.email_outlined,
                                size: 18, color: AppColor.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColor.textSecondary,
                                  ),
                                ),
                                Text(
                                  user?.email ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Tidak bisa diubah',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColor.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Alamat Tersimpan ────────────────
                  const AnimatedFadeSlider(
                    index: 8,
                    child: _SectionLabel(label: 'Alamat Tersimpan'),
                  ),
                  const SizedBox(height: 10),

                  ...List.generate(user?.addresses.length ?? 0, (idx) {
                    final addr = user!.addresses[idx];
                    return AnimatedFadeSlider(
                      index: 9 + idx,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColor.divider),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                addr.isDefault
                                    ? Icons.home_rounded
                                    : Icons.location_on_outlined,
                                size: 18,
                                color: AppColor.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (addr.label != null)
                                        Text(
                                          addr.label!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.textPrimary,
                                          ),
                                        ),
                                      if (addr.isDefault) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
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
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    addr.address,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColor.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // ── Tambah Alamat ────────────────────
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => setState(() => _showAddAddress = !_showAddAddress),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColor.primary.withValues(alpha: 0.2),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showAddAddress
                                ? Icons.remove_circle_outline
                                : Icons.add_circle_outline,
                            size: 18,
                            color: AppColor.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showAddAddress
                                ? 'Tutup'
                                : 'Tambah Alamat Baru',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showAddAddress) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newAddressCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Alamat lengkap',
                        hintText: 'Masukkan alamat baru',
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
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => setState(() => _saveAddress = !_saveAddress),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              _saveAddress
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded,
                              size: 22,
                              color: _saveAddress
                                  ? AppColor.primary
                                  : AppColor.textMuted,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Simpan alamat ini',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColor.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_saveAddress) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _newLabelCtrl,
                        decoration: InputDecoration(
                          labelText: 'Label lokasi',
                          hintText: 'Rumah, Kantor, Sekolah',
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
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColor.textSecondary,
        ),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _EditableField({
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divider),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: AppColor.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: AppColor.textSecondary),
          prefixIcon: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: AppColor.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

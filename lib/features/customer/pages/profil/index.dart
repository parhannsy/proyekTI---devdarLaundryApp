import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_bar.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/mini_stat_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Column(
        children: [
          const MinimalBar(title: 'Profil'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              children: [
                const AnimatedFadeSlider(index: 1, child: _ProfileHeader()),
                const SizedBox(height: 20),
                const AnimatedFadeSlider(
                  index: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _StatsRow(),
                  ),
                ),
                const SizedBox(height: 20),
                const AnimatedFadeSlider(index: 3, child: _SectionLabel(label: 'Akun')),
                const SizedBox(height: 10),
                AnimatedFadeSlider(
                  index: 4,
                  child: _ProfileMenuItem(
                    icon: Icons.person_outline,
                    label: 'Edit Profil',
                    onTap: () => _showEditProfileDialog(context),
                  ),
                ),
                AnimatedFadeSlider(
                  index: 5,
                  child: _ProfileMenuItem(
                    icon: Icons.lock_outline,
                    label: 'Ganti Sandi',
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                ),
                const AnimatedFadeSlider(index: 6, child: _ProfileMenuItem(icon: Icons.confirmation_number_outlined, label: 'Voucher Saya')),
                const AnimatedFadeSlider(index: 7, child: _ProfileMenuItem(icon: Icons.history, label: 'Riwayat Order')),
                const AnimatedFadeSlider(index: 8, child: _ProfileMenuItem(icon: Icons.people_outline, label: 'Program Afiliasi')),
                const SizedBox(height: 20),
                const AnimatedFadeSlider(index: 9, child: _SectionLabel(label: 'Lainnya')),
                const SizedBox(height: 10),
                const AnimatedFadeSlider(index: 10, child: _ProfileMenuItem(icon: Icons.notifications_none, label: 'Notifikasi')),
                const AnimatedFadeSlider(index: 11, child: _ProfileMenuItem(icon: Icons.help_outline, label: 'Bantuan')),
                AnimatedFadeSlider(
                  index: 12,
                  child: _ProfileMenuItem(
                    icon: Icons.logout,
                    label: 'Keluar',
                    color: AppColor.error,
                    onTap: () => _confirmLogout(context, auth),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?'),
        content: const Text('Anda akan keluar dari akun ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                context.go('/');
                auth.logout();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.error),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.name);
    final nicknameCtrl = TextEditingController(text: user.nickname ?? '');
    final phoneCtrl = TextEditingController(text: user.phone);
    final addressCtrl = TextEditingController(text: user.address ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ProfileField(label: 'Nama Lengkap', controller: nameCtrl),
              const SizedBox(height: 10),
              _ProfileField(label: 'Panggilan', controller: nicknameCtrl),
              const SizedBox(height: 10),
              _ProfileField(label: 'No. Telepon', controller: phoneCtrl, keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _ProfileField(label: 'Alamat', controller: addressCtrl, maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await auth.updateProfile(
                  name: nameCtrl.text.trim(),
                  nickname: nicknameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil berhasil diperbarui'),
                      backgroundColor: AppColor.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal: ${e.toString().replaceFirst('Exception: ', '')}'),
                      backgroundColor: AppColor.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ganti Sandi'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PasswordField(controller: currentPwCtrl, hint: 'Password Lama'),
              const SizedBox(height: 10),
              _PasswordField(controller: newPwCtrl, hint: 'Password Baru'),
              const SizedBox(height: 10),
              _PasswordField(controller: confirmPwCtrl, hint: 'Konfirmasi Password Baru'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              if (newPwCtrl.text != confirmPwCtrl.text) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Password baru tidak cocok'),
                    backgroundColor: AppColor.error,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                final auth = context.read<AuthProvider>();
                await auth.changePassword(
                  currentPassword: currentPwCtrl.text,
                  newPassword: newPwCtrl.text,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password berhasil diubah!'),
                      backgroundColor: AppColor.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal: ${e.toString().replaceFirst('Exception: ', '')}'),
                      backgroundColor: AppColor.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const _PasswordField({
    required this.controller,
    required this.hint,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        labelText: widget.hint,
        labelStyle: const TextStyle(fontSize: 13, color: AppColor.textSecondary),
        filled: true,
        fillColor: AppColor.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: IconButton(
          icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility, size: 18),
          onPressed: () => setState(() => _obscured = !_obscured),
          color: AppColor.textSecondary,
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  const _ProfileField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppColor.textSecondary),
        filled: true,
        fillColor: AppColor.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final displayName = user?.name ?? 'Pelanggan';
    final email = user?.email ?? '';

    return MinimalCard(
      radius: 14,
      withBorder: true,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColor.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.textPrimary)),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final points = user?.loyaltyPoints ?? 0;
    final savings = user?.totalSavings ?? 0;

    return Row(
      children: [
        MiniStatCard(label: 'Poin', value: '$points', icon: Icons.star_rounded, color: AppColor.warning, showIconBackground: true),
        const SizedBox(width: 12),
        MiniStatCard(label: 'Total Hemat', value: 'Rp ${_formatSavings(savings)}', icon: Icons.savings_outlined, color: AppColor.success, showIconBackground: true),
        const SizedBox(width: 12),
        MiniStatCard(label: 'Order', value: '14x', icon: Icons.inventory_2_outlined, color: AppColor.primary, showIconBackground: true),
      ],
    );
  }

  String _formatSavings(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.textSecondary)),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ProfileMenuItem({required this.icon, required this.label, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColor.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: MinimalCard(
        radius: 12, withBorder: true,
        padding: const EdgeInsets.all(14),
        onTap: onTap ?? () => debugPrint('Menu $label diklik'),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, color: itemColor, fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.chevron_right, color: AppColor.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_page_header.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AnimatedFadeSlider(
              index: 1,
              child: AdminPageHeader(
                title: 'Pengaturan',
                subtitle: 'Profil dan konfigurasi sistem',
              ),
            ),
            AnimatedFadeSlider(
              index: 2,
              child: _ProfileCard(name: user?.name, email: user?.email),
            ),
            const SizedBox(height: 24),
            AnimatedFadeSlider(
              index: 3,
              child: _SectionLabel(title: 'Profil Admin'),
            ),
            AnimatedFadeSlider(
              index: 4,
              child: _SectionCard(
                children: [
                  _SettingsItem(
                    icon: Icons.person_outline,
                    label: 'Edit Nama',
                    onTap: () =>
                        _showEditDialog(context, 'name', 'Nama', user?.name ?? ''),
                  ),
                  _SettingsItem(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user?.email,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email tidak dapat diubah dari sini'),
                          backgroundColor: AppColor.info,
                        ),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.phone_outlined,
                    label: 'Nomor Telepon',
                    value: user?.phone,
                    onTap: () =>
                        _showEditDialog(context, 'phone', 'Telepon', user?.phone ?? ''),
                  ),
                  _SettingsItem(
                    icon: Icons.lock_outline,
                    label: 'Ubah Password',
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedFadeSlider(
              index: 5,
              child: _SectionLabel(title: 'Pengaturan Bisnis'),
            ),
            AnimatedFadeSlider(
              index: 6,
              child: _SectionCard(
                children: [
                  _SettingsItem(
                    icon: Icons.store_outlined,
                    label: 'Info Toko',
                    onTap: () {},
                  ),

                  _SettingsItem(
                    icon: Icons.local_shipping_outlined,
                    label: 'Area Pengiriman',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.access_time,
                    label: 'Jam Operasional',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedFadeSlider(
              index: 7,
              child: _SectionLabel(title: 'Notifikasi'),
            ),
            AnimatedFadeSlider(
              index: 8,
              child: _SectionCard(
                children: const [
                  _SettingsToggle(
                    icon: Icons.notifications_outlined,
                    label: 'Notifikasi Order Baru',
                    value: true,
                  ),

                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedFadeSlider(
              index: 9,
              child: _SectionLabel(title: 'Tentang Aplikasi'),
            ),
            AnimatedFadeSlider(
              index: 10,
              child: _SectionCard(
                children: [
                  _SettingsItem(
                    icon: Icons.info_outline,
                    label: 'Versi Aplikasi',
                    value: 'v0.1.0',
                    onTap: () {},
                  ),

                ],
              ),
            ),
            const SizedBox(height: 24),
            AnimatedFadeSlider(
              index: 11,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmLogout(context, auth),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.error.withValues(alpha: 0.1),
                    foregroundColor: AppColor.error,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: AppColor.error.withValues(alpha: 0.3),
                    ),
                  ),
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String fieldKey, String fieldLabel, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $fieldLabel'),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: fieldLabel,
            filled: true,
            fillColor: AppColor.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final auth = context.read<AuthProvider>();
              try {
                final value = ctrl.text.trim();
                switch (fieldKey) {
                  case 'name':
                    await auth.updateProfile(name: value);
                  case 'phone':
                    await auth.updateProfile(phone: value);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$fieldLabel diperbarui'),
                      backgroundColor: AppColor.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal: ${e.toString()}'),
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ubah Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AdminPwField(controller: currentPwCtrl, hint: 'Password Lama'),
              const SizedBox(height: 10),
              _AdminPwField(controller: newPwCtrl, hint: 'Password Baru'),
              const SizedBox(height: 10),
              _AdminPwField(controller: confirmPwCtrl, hint: 'Konfirmasi Password Baru'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              if (newPwCtrl.text != confirmPwCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password baru tidak cocok'),
                    backgroundColor: AppColor.error,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              final auth = context.read<AuthProvider>();
              try {
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

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?'),
        content: const Text('Anda akan keluar dari sesi admin.'),
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
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String? name;
  final String? email;
  const _ProfileCard({this.name, this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), AppColor.primary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'Admin Devdara',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email ?? 'admin@devdara.com',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Administrator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColor.textSecondary,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(children: children),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColor.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
            if (value != null) ...[
              Expanded(
                child: Text(
                  value!,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColor.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColor.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminPwField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const _AdminPwField({
    required this.controller,
    required this.hint,
  });

  @override
  State<_AdminPwField> createState() => _AdminPwFieldState();
}

class _AdminPwFieldState extends State<_AdminPwField> {
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

class _SettingsToggle extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool value;

  const _SettingsToggle({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  State<_SettingsToggle> createState() => _SettingsToggleState();
}

class _SettingsToggleState extends State<_SettingsToggle> {
  late bool _val;

  @override
  void initState() {
    super.initState();
    _val = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(widget.icon, size: 20, color: AppColor.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 14, color: AppColor.textPrimary),
            ),
          ),
          Switch.adaptive(
            value: _val,
            onChanged: (v) => setState(() => _val = v),
            activeTrackColor: AppColor.primary,
          ),
        ],
      ),
    );
  }
}



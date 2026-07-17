import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:devdar_laundry_pos_app/core/router/app_router.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      await auth.completeProfile(
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (!mounted) return;
      // Profil sudah lengkap, sekarang tampilkan welcome splash
      context.go(AppRoutes.welcomeSplash);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan profil: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: AppColor.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // ── Header ─────────────────────────────────
                  ClayContainer(
                    radius: 40,
                    elevation: 6,
                    surfaceColor: AppColor.primary,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColor.primary, AppColor.primaryDark],
                    ),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        ClayContainer(
                          radius: 20,
                          elevation: 5,
                          surfaceColor: Colors.white.withValues(alpha: 0.2),
                          padding: const EdgeInsets.all(16),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Lengkapi Profil Kamu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Isi data diri kamu agar kami bisa melayani lebih baik',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  // ── Form ────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: ClayContainer(
                        radius: 24,
                        elevation: 6,
                        surfaceColor: AppColor.surface,
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                label: 'Nama Lengkap',
                                hint: 'Contoh: Ahmad Farhan',
                                icon: Icons.person_outline,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Nama lengkap wajib diisi';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _nicknameController,
                                label: 'Nama Panggilan',
                                hint: 'Contoh: Ahmad',
                                icon: Icons.face_outlined,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Nama panggilan wajib diisi';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Nomor HP',
                                hint: 'Contoh: 081234567890',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Nomor HP wajib diisi';
                                  if (v.trim().length < 10) return 'Nomor HP minimal 10 digit';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _addressController,
                                label: 'Alamat',
                                hint: 'Contoh: Jl. Merdeka No. 123, Jakarta',
                                icon: Icons.home_outlined,
                                maxLines: 3,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Alamat wajib diisi';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Tombol Submit
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return ClayContainer(
                                    radius: 14,
                                    elevation: _isLoading ? 2 : 5,
                                    pressed: _isLoading,
                                    surfaceColor: AppColor.primary,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [AppColor.primary, AppColor.primaryDark],
                                    ),
                                    padding: EdgeInsets.zero,
                                    height: 52,
                                    child: InkWell(
                                      onTap: _isLoading ? null : _handleSubmit,
                                      borderRadius: BorderRadius.circular(14),
                                      child: Center(
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : const Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Simpan & Lanjutkan',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.arrow_forward,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppColor.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColor.textMuted, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColor.iconSecondary, size: 20),
            filled: true,
            fillColor: AppColor.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

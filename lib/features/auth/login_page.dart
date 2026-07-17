import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/core/models/user_model.dart';
import 'package:devdar_laundry_pos_app/core/router/app_router.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;

  // Animasi entrance bertahap ala claymorphism
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _hints = [
    _CredentialHint(
      label: 'Customer Demo',
      email: 'customer@devdara.com',
      password: 'customer123',
      icon: Icons.person_outline,
      color: AppColor.primary,
    ),
    _CredentialHint(
      label: 'Admin Demo',
      email: 'admin@devdara.com',
      password: 'admin123',
      icon: Icons.admin_panel_settings_outlined,
      color: Color(0xFF7B1FA2),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (auth.status == AuthStatus.authenticated) {
      if (auth.currentUser?.role == UserRole.admin) {
        context.go(AppRoutes.adminDashboard);
      } else {
        final user = auth.currentUser;
        // Jika profil belum lengkap → minta lengkapi dulu
        if (user?.isProfileComplete == false) {
          context.go(AppRoutes.completeProfile);
        } else if (user?.hasSeenSplash == true) {
          context.go(AppRoutes.customerDashboard);
        } else {
          context.go(AppRoutes.welcomeSplash);
        }
      }
    }
  }

  void _fillCredential(_CredentialHint hint) {
    _emailController.text = hint.email;
    _passwordController.text = hint.password;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 680;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  _buildHeader(isSmall),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: _buildFormCard(context),
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

  Widget _buildHeader(bool isSmall) {
    return ClayContainer(
      radius: 40,
      elevation: 6,
      pressed: false,
      surfaceColor: AppColor.primary,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColor.primary, AppColor.primaryDark],
      ),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        isSmall ? 28 : 48,
        24,
        isSmall ? 24 : 40,
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          // Logo dengan clay effect
          ClayContainer(
            radius: 20,
            elevation: 5,
            surfaceColor: Colors.white.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.water_drop_outlined,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Devdara Laundry',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cuci Bersih, Hidup Segar',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Demo credential chips — claymorphism style
          _buildDemoChips(),
          const SizedBox(height: 20),

          // Form card utama — claymorphism raised
          ClayContainer(
            radius: 24,
            elevation: 6,
            surfaceColor: AppColor.surface,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Masuk ke Akun',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Masukkan email dan password kamu',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField(
                    controller: _emailController,
                    hint: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Email wajib diisi';
                      if (!val.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: _isObscure,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColor.iconSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Password wajib diisi';
                      if (val.length < 6) return 'Password minimal 6 karakter';
                      return null;
                    },
                  ),

                  // Error message
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.errorMessage == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClayContainer(
                          radius: 10,
                          elevation: 2,
                          pressed: true,
                          surfaceColor: AppColor.error.withValues(alpha: 0.08),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColor.error,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.errorMessage!,
                                  style: const TextStyle(
                                    color: AppColor.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Submit button — claymorphism
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final isLoading = auth.status == AuthStatus.loading;
                      return ClayContainer(
                        radius: 14,
                        elevation: isLoading ? 2 : 5,
                        pressed: isLoading,
                        surfaceColor: AppColor.primary,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isLoading
                              ? [
                                  AppColor.primary.withValues(alpha: 0.8),
                                  AppColor.primaryDark.withValues(alpha: 0.8),
                                ]
                              : [AppColor.primary, AppColor.primaryDark],
                        ),
                        padding: EdgeInsets.zero,
                        height: 52,
                        child: InkWell(
                          onTap: isLoading ? null : _handleLogin,
                          borderRadius: BorderRadius.circular(14),
                          child: Center(
                            child: isLoading
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
                                        'Masuk',
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
        ],
      ),
    );
  }

  Widget _buildDemoChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coba dengan akun demo:',
          style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: _hints
              .map(
                (hint) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () => _fillCredential(hint),
                    borderRadius: BorderRadius.circular(20),
                    child: ClayContainer(
                      radius: 20,
                      elevation: 3,
                      surfaceColor: hint.color.withValues(alpha: 0.08),
                      borderColor: hint.color.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(hint.icon, size: 14, color: hint.color),
                          const SizedBox(width: 6),
                          Text(
                            hint.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: hint.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColor.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColor.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColor.iconSecondary, size: 20),
        suffixIcon: suffixIcon,
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class _CredentialHint {
  final String label;
  final String email;
  final String password;
  final IconData icon;
  final Color color;

  const _CredentialHint({
    required this.label,
    required this.email,
    required this.password,
    required this.icon,
    required this.color,
  });
}

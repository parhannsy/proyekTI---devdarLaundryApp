import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:devdar_laundry_pos_app/core/router/app_router.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';

class WelcomeSplashPage extends StatefulWidget {
  const WelcomeSplashPage({super.key});

  @override
  State<WelcomeSplashPage> createState() => _WelcomeSplashPageState();
}

class _WelcomeSplashPageState extends State<WelcomeSplashPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  static const _features = [
    _SplashFeature(
      icon: Icons.track_changes_rounded,
      color: Color(0xFF42A5F5),
      title: 'Pantau Order Real-Time',
      subtitle:
          'Lacak status cucian kamu dari diterima hingga siap diambil, kapan saja dan di mana saja.',
    ),
    _SplashFeature(
      icon: Icons.confirmation_number_outlined,
      color: Color(0xFF66BB6A),
      title: 'Voucher & Diskon Eksklusif',
      subtitle:
          'Hemat lebih banyak dengan voucher diskon yang selalu diperbarui setiap minggunya.',
    ),
    _SplashFeature(
      icon: Icons.star_rounded,
      color: Color(0xFFFFA726),
      title: 'Misi & Poin Reward',
      subtitle:
          'Selesaikan misi, kumpulkan poin, dan tukarkan dengan hadiah menarik dari Devdara.',
    ),
    _SplashFeature(
      icon: Icons.people_outline_rounded,
      color: Color(0xFFAB47BC),
      title: 'Program Afiliasi',
      subtitle:
          'Ajak teman dan dapatkan komisi. Semakin banyak referral, semakin besar penghasilan kamu.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    _logoController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _features.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishSplash();
    }
  }

  void _skip() => _finishSplash();

  void _finishSplash() {
    // Tandai bahwa user sudah lihat splash → lain kali langsung dashboard
    context.read<AuthProvider>().markSplashSeen();
    context.go(AppRoutes.customerDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header logo ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: ClayContainer(
                        radius: 14,
                        elevation: 5,
                        surfaceColor: AppColor.primary,
                        padding: const EdgeInsets.all(10),
                        child: const Icon(
                          Icons.water_drop_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FadeTransition(
                    opacity: _logoFade,
                    child: const Text(
                      'Devdara',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── PageView fitur ─────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemCount: _features.length,
                itemBuilder: (context, index) {
                  return _FeaturePage(
                    feature: _features[index],
                    screenHeight: size.height,
                  );
                },
              ),
            ),

            // ── Dot indicator & tombol ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _features.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColor.primary
                              : AppColor.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol claymorphism
                  ClayContainer(
                    radius: 16,
                    elevation: 5,
                    surfaceColor: AppColor.primary,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColor.primary, AppColor.primaryDark],
                    ),
                    padding: EdgeInsets.zero,
                    width: double.infinity,
                    height: 54,
                    child: InkWell(
                      onTap: _next,
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Text(
                          _currentPage < _features.length - 1
                              ? 'Selanjutnya'
                              : 'Mulai Sekarang',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePage extends StatelessWidget {
  final _SplashFeature feature;
  final double screenHeight;

  const _FeaturePage({required this.feature, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustrasi ikon — claymorphism layered circles
          ClayContainer(
            radius: screenHeight * 0.11,
            elevation: 6,
            surfaceColor: feature.color.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(24),
            child: ClayContainer(
              radius: screenHeight * 0.07,
              elevation: 4,
              surfaceColor: feature.color.withValues(alpha: 0.15),
              padding: EdgeInsets.all(screenHeight * 0.035),
              child: Icon(
                feature.icon,
                color: feature.color,
                size: screenHeight * 0.07,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          Text(
            feature.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenHeight < 600 ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            feature.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColor.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashFeature {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _SplashFeature({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

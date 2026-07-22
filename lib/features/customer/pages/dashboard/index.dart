import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/providers/order_provider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_bar.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/area_active_order.dart';
import 'widgets/area_saving_card.dart';
import 'widgets/area_mission_tracker.dart';
import 'widgets/area_banner_promo.dart';
import 'widgets/area_quick_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startStream();
    });
  }

  @override
  void dispose() {
    // Stream dihentikan otomatis saat page lain dipanggil
    // karena listenCustomerOrders akan cancel subscription sebelumnya
    super.dispose();
  }

  void _startStream() {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user != null) {
      // Realtime — setiap perubahan dari Firestore langsung update dashboard
      context.read<OrderProvider>().listenCustomerOrders(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Column(
        children: [
          const MinimalBar(
            title: 'Beranda',
            showNotification: true,
            notificationCount: 3,
          ),
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProv, _) {
                final activeOrders = orderProv.orders
                    .where((o) => o.status.isActive)
                    .toList();

                return ListView(
                  padding: const EdgeInsets.only(top: 16, bottom: 100),
                  children: [
                    // Greeting section
                    AnimatedFadeSlider(
                      index: 1,
                      child: const _GreetingSection(),
                    ),
                    const SizedBox(height: 20),

                    // Quick actions
                    AnimatedFadeSlider(
                      index: 2,
                      child: const BuildQuickActions(),
                    ),
                    const SizedBox(height: 20),

                    // Promo banners
                    AnimatedFadeSlider(
                      index: 3,
                      child: const _SectionHeader(title: 'Promo Spesial'),
                    ),
                    const SizedBox(height: 10),
                    AnimatedFadeSlider(
                      index: 4,
                      child: const BuildPromoBanners(),
                    ),
                    const SizedBox(height: 20),

                    // Active orders — real data
                    AnimatedFadeSlider(
                      index: 5,
                      child: _SectionHeader(
                        title: activeOrders.isNotEmpty
                            ? 'Pesanan Aktif (${activeOrders.length})'
                            : 'Pesanan Aktif',
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedFadeSlider(
                      index: 6,
                      child: BuildActiveOrdersSection(
                        orders: activeOrders,
                        isLoading: orderProv.isLoading,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mission tracker
                    AnimatedFadeSlider(
                      index: 7,
                      child: const _SectionHeader(title: 'Misi Berlangsung'),
                    ),
                    const SizedBox(height: 10),
                    AnimatedFadeSlider(
                      index: 8,
                      child: const BuildOngoingMissions(),
                    ),
                    const SizedBox(height: 20),

                    // Monthly savings
                    AnimatedFadeSlider(
                      index: 9,
                      child: const _SectionHeader(title: 'Hemat Bulan Ini'),
                    ),
                    const SizedBox(height: 10),
                    AnimatedFadeSlider(
                      index: 10,
                      child: const BuildMonthlySavings(),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final displayName = user?.nickname ?? user?.name ?? 'Pelanggan';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(),
            style: const TextStyle(
              fontSize: 14,
              color: AppColor.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$displayName 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColor.textPrimary,
        ),
      ),
    );
  }
}

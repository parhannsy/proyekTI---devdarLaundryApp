import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/shimmer_loader.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/top_bar.dart';
import 'package:flutter/material.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulasi loading untuk memperlihatkan shimmer
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: const FloatingTopbar(),
          ),
        ],
        body: Builder(
          builder: (context) => CustomScrollView(
            primary: true,
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  if (_isLoading) ...[
                    // ── Shimmer loading state ───────────────────
                    const SizedBox(height: 16),
                    const ShimmerGrid(),
                    const ShimmerHorizontalList(),
                    const ShimmerCard(),
                    const ShimmerCard(height: 80),
                    const ShimmerCard(height: 70),
                  ] else ...[
                    const AnimatedFadeSlider(
                      index: 1,
                      child: BuildQuickActions(),
                    ),
                    const AnimatedFadeSlider(
                      index: 2,
                      child: BuildPromoBanners(),
                    ),
                    const AnimatedFadeSlider(
                      index: 3,
                      child: BuildActiveOrdersSection(),
                    ),
                    const AnimatedFadeSlider(
                      index: 4,
                      child: BuildOngoingMissions(),
                    ),
                    const AnimatedFadeSlider(
                      index: 5,
                      child: BuildMonthlySavings(),
                    ),
                  ],
                  const SizedBox(height: 120),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

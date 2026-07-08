import 'package:devdar_laundry_pos_app/core/theme/formatter/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/widgets/customer/top_bar.dart';
import 'package:flutter/material.dart';
import 'widgets/area_active_order.dart';
import 'widgets/area_saving_card.dart';
import 'widgets/area_mission_tracker.dart';
import 'widgets/area_banner_promo.dart';
import 'widgets/area_quick_menu.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
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
                  // Padding bawah agar konten tidak tertutup FloatingBottomBar
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

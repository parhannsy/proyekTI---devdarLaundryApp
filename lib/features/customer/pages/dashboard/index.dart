import 'package:devdar_laundry_pos_app/core/theme/formatter/animated_fade_slider.dart';
import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/dashboard/widgets/area_active_order.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/dashboard/widgets/area_saving_card.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/dashboard/widgets/area_mission_tracker.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/dashboard/widgets/area_banner_promo.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/dashboard/widgets/area_quick_menu.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      primary: true,
      slivers: [
        Builder(
          builder: (context) => SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
        ),

        SliverList(
          delegate: SliverChildListDelegate([
            // Elemen 1: Quick Actions
            const AnimatedFadeSlider(
              index: 1, 
              child: BuildQuickActions(),
            ),
            const SizedBox(height: 16),
            
            // Elemen 2: Promo Banners
            const AnimatedFadeSlider(
              index: 2, 
              child: BuildPromoBanners(),
            ),
            
            // Elemen 3: Active Orders
            const AnimatedFadeSlider(
              index: 3, 
              child: BuildActiveOrdersSection(),
            ),

            // Elemen 4: Missions
            const AnimatedFadeSlider(
              index: 4, 
              child: BuildOngoingMissions(),
            ),
            
            const AnimatedFadeSlider(
              index: 5, 
              child: BuildMonthlySavings(),
            ),
            SizedBox(height: 150),
          ]),
        ),
      ],
    );
  }
}
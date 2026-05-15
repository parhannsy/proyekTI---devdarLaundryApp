import 'package:devdar_laundry_pos_app/core/theme/formatter/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/mission/widgets/area_active_mission.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/mission/widgets/area_available_mission.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/mission/widgets/area_completted_mission.dart';
import 'package:flutter/material.dart';

class MissionPage extends StatelessWidget {
  const MissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      primary: true,
      slivers: [
        // Menangani overlap dengan TopBar melayang agar konsisten
        Builder(
          builder: (context) => SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
        ),

        SliverList(
          delegate: SliverChildListDelegate([
            // Elemen 1: Section Misi Aktif (Horizontal)
            const AnimatedFadeSlider(
              index: 1,
              child: ActiveMissionCard(),
            ),

            // Elemen 2: Section Misi Tersedia
            const AnimatedFadeSlider(
              index: 2,
              child: AvailableMissionCard(),
            ),

            // Elemen 3: Section Misi Selesai
            const AnimatedFadeSlider(
              index: 3,
              child: CompletedMissionCard(),
            ),

            // Padding bawah agar item terakhir tidak tertutup Floating Bottom Bar
            const SizedBox(height: 150),
          ]),
        ),
      ],
    );
  }
}
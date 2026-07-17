import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_bar.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/mission/widgets/area_active_mission.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/mission/widgets/area_available_mission.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/mission/widgets/area_completted_mission.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';

class MissionPage extends StatelessWidget {
  const MissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Column(
        children: [
          const MinimalBar(title: 'Misi & Reward'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              children: const [
                AnimatedFadeSlider(
                  index: 1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Misi Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.textPrimary)),
                  ),
                ),
                SizedBox(height: 10),
                AnimatedFadeSlider(index: 2, child: SizedBox(height: 180, child: _ActiveMissionsList())),
                SizedBox(height: 20),
                AnimatedFadeSlider(
                  index: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Misi Tersedia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.textPrimary)),
                  ),
                ),
                SizedBox(height: 10),
                AnimatedFadeSlider(index: 4, child: AvailableMissionCard(title: 'Order 5x Dalam Sebulan', reward: 'Diskon 15% untuk order berikutnya', icon: Icons.repeat_rounded)),
                AnimatedFadeSlider(index: 5, child: AvailableMissionCard(title: 'Ajak 3 Teman', reward: 'Gratis 1x cuci reguler', icon: Icons.people_outline_rounded)),
                AnimatedFadeSlider(index: 6, child: AvailableMissionCard(title: 'Belanja Total Rp 300.000', reward: 'Bonus 100 poin loyalitas', icon: Icons.shopping_bag_outlined)),
                SizedBox(height: 20),
                AnimatedFadeSlider(
                  index: 7,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Misi Selesai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.textPrimary)),
                  ),
                ),
                SizedBox(height: 10),
                AnimatedFadeSlider(index: 8, child: CompletedMissionCard(title: 'Order Pertama', description: 'Voucher diskon 20% telah dikirim')),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveMissionsList extends StatelessWidget {
  const _ActiveMissionsList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: const [
        ActiveMissionCard(title: 'Order 5x Dalam Sebulan', reward: 'Diskon 15%', deadline: '18 hari lagi', currentProgress: 3, totalProgress: 5),
        SizedBox(width: 12),
        ActiveMissionCard(title: 'Belanja Rp 300.000', reward: 'Bonus 100 poin', deadline: '18 hari lagi', currentProgress: 185000, totalProgress: 300000),
      ],
    );
  }
}

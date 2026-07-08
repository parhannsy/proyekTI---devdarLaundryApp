import 'package:devdar_laundry_pos_app/core/theme/formatter/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/mission/widgets/area_active_mission.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/mission/widgets/area_available_mission.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/mission/widgets/area_completted_mission.dart';
import 'package:flutter/material.dart';

class MissionPage extends StatelessWidget {
  const MissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text(
          'Misi & Reward',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: const [
          AnimatedFadeSlider(
            index: 1,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Misi Aktif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
          ),
          AnimatedFadeSlider(
            index: 2,
            child: SizedBox(height: 180, child: _ActiveMissionsList()),
          ),
          SizedBox(height: 8),
          AnimatedFadeSlider(
            index: 3,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Misi Tersedia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
          ),
          AnimatedFadeSlider(
            index: 4,
            child: AvailableMissionCard(
              title: 'Order 5x Dalam Sebulan',
              reward: 'Diskon 15% untuk order berikutnya',
              icon: Icons.repeat_rounded,
            ),
          ),
          AnimatedFadeSlider(
            index: 5,
            child: AvailableMissionCard(
              title: 'Ajak 3 Teman',
              reward: 'Gratis 1x cuci reguler',
              icon: Icons.people_outline_rounded,
            ),
          ),
          AnimatedFadeSlider(
            index: 6,
            child: AvailableMissionCard(
              title: 'Belanja Total Rp 300.000',
              reward: 'Bonus 100 poin loyalitas',
              icon: Icons.shopping_bag_outlined,
            ),
          ),
          SizedBox(height: 8),
          AnimatedFadeSlider(
            index: 7,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Misi Selesai',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
          ),
          AnimatedFadeSlider(
            index: 8,
            child: CompletedMissionCard(
              title: 'Order Pertama',
              description: 'Voucher diskon 20% telah dikirim',
            ),
          ),
        ],
      ),
    );
  }
}

/// Daftar kartu misi aktif dalam scroll horizontal
class _ActiveMissionsList extends StatelessWidget {
  const _ActiveMissionsList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: const [
        ActiveMissionCard(
          title: 'Order 5x Dalam Sebulan',
          reward: 'Diskon 15%',
          deadline: '18 hari lagi',
          currentProgress: 3,
          totalProgress: 5,
        ),
        SizedBox(width: 12),
        ActiveMissionCard(
          title: 'Belanja Rp 300.000',
          reward: 'Bonus 100 poin',
          deadline: '18 hari lagi',
          currentProgress: 185000,
          totalProgress: 300000,
        ),
      ],
    );
  }
}

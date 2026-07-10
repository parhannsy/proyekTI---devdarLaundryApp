import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';
import 'package:flutter/material.dart';

class AvailableMissionCard extends StatelessWidget {
  final String title, reward;
  final IconData icon;
  final bool isLocked;

  const AvailableMissionCard({
    super.key,
    this.title = 'Misi Baru Tersedia',
    this.reward = 'Reward Menarik',
    this.icon = Icons.star_border_rounded,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      radius: 20,
      elevation: 4,
      surfaceColor: isLocked ? Colors.grey.shade50.withValues(alpha: 0.5) : Colors.white,
      borderColor: Colors.blue.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: isLocked ? Colors.grey : AppColor.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: isLocked ? Colors.grey : Colors.black87
                )),
                Text(reward, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          if (!isLocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Mulai', 
                style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold)
              ),
            ),
        ],
      ),
    );
  }
}
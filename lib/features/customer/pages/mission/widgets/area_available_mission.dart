import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade50.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade50),
      ),
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
                color: Colors.blue.shade50,
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
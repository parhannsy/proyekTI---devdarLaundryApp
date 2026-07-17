import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: MinimalCard(
        radius: 12, withBorder: true,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: isLocked ? AppColor.textMuted : AppColor.primary, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                    color: isLocked ? AppColor.textMuted : AppColor.textPrimary)),
                  const SizedBox(height: 4),
                  Text(reward, style: const TextStyle(color: AppColor.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (!isLocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Mulai', style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
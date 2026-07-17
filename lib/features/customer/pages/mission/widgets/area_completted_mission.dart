import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';

class CompletedMissionCard extends StatelessWidget {
  final String title, description;

  const CompletedMissionCard({
    super.key,
    this.title = 'Misi Berhasil Diselesaikan',
    this.description = 'Reward telah diklaim',
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColor.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.check_circle_outline_rounded, color: AppColor.success, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColor.textPrimary)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: AppColor.success, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
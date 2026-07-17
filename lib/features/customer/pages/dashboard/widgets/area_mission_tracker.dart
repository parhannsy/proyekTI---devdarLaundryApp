import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';

class BuildOngoingMissions extends StatelessWidget {
  const BuildOngoingMissions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MinimalCard(
        radius: 12, withBorder: true,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColor.warning.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.star, color: AppColor.warning, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order 5x dalam sebulan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.textPrimary)),
                      SizedBox(height: 4),
                      Text('Dapatkan diskon 15%', style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
                    ],
                  ),
                ),
                const Text('3/5', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColor.primary)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: const LinearProgressIndicator(
                value: 0.6,
                backgroundColor: Color(0xFFF0F0F0),
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
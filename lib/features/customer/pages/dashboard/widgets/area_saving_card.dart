import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';

class BuildMonthlySavings extends StatelessWidget {
  const BuildMonthlySavings({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MinimalCard(
        radius: 12, withBorder: true,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColor.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.savings_outlined, color: AppColor.success, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total hemat bulan ini', style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
                SizedBox(height: 4),
                Text('Rp 125.000', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.success)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
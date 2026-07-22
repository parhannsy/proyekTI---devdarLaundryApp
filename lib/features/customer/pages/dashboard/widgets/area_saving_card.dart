import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/currency_formatter.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';

class BuildMonthlySavings extends StatelessWidget {
  const BuildMonthlySavings({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final totalSavings = user?.totalSavings ?? 125000;

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total hemat bulan ini', style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
                const SizedBox(height: 4),
                Text(formatRupiah(totalSavings), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.success)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
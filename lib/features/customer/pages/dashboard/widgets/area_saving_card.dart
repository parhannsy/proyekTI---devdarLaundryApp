import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';
import 'package:flutter/material.dart';

class BuildMonthlySavings extends StatelessWidget {
  const BuildMonthlySavings({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClayContainer(
        radius: 16,
        elevation: 4,
        surfaceColor: AppColor.surface,
        padding: const EdgeInsets.all(16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total hemat bulan ini',
              style: TextStyle(
                fontSize: 12,
                color: AppColor.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Rp 125.000',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
  }
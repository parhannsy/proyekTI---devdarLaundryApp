import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';

/// Kartu statistik kecil yang bisa dipakai baik di halaman admin maupun customer.
///
/// Dua mode tampilan:
/// - [showIconBackground]=true  → icon dibungkus lingkaran dengan warna transparan (profil customer)
/// - [showIconBackground]=false → icon polos tanpa background (halaman admin customer)
class MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool showIconBackground;
  final double iconSize;
  final double valueFontSize;
  final double labelFontSize;

  const MiniStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.showIconBackground = false,
    this.iconSize = 18,
    this.valueFontSize = 15,
    this.labelFontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClayContainer(
        radius: 16,
        elevation: 3,
        surfaceColor: AppColor.surface,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            if (showIconBackground)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: iconSize),
              )
            else
              Icon(icon, color: color, size: iconSize),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: labelFontSize,
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

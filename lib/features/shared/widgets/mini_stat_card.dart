import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';

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
      child: MinimalCard(
        radius: 12,
        withBorder: true,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            if (showIconBackground)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: iconSize),
              )
            else
              Icon(icon, color: color, size: iconSize),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/router/app_router.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';

class BuildQuickActions extends StatelessWidget {
  const BuildQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _ActionItem(
            icon: Icons.add_circle_outline,
            label: 'Order Baru',
            color: AppColor.primary,
            onTap: () => context.push<bool>(
              '${AppRoutes.customerOrders}/create',
            ),
          ),
          const SizedBox(width: 10),
          _ActionItem(
            icon: Icons.history,
            label: 'Riwayat',
            color: const Color(0xFF7B1FA2),
            onTap: () => context.go(AppRoutes.customerOrders),
          ),
          const SizedBox(width: 10),
          _ActionItem(
            icon: Icons.confirmation_number_outlined,
            label: 'Diskon Saya',
            color: AppColor.success,
          ),
          const SizedBox(width: 10),
          _ActionItem(
            icon: Icons.people_outline,
            label: 'Afiliasi',
            color: AppColor.warning,
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MinimalCard(
        radius: 12,
        withBorder: false,
        withShadow: false,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColor.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
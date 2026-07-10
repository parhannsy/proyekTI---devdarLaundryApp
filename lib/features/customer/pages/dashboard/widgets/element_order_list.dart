import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';
import 'package:flutter/material.dart';

/// Widget kartu order yang dapat digunakan kembali di mana saja.
/// Menggantikan function builder lama agar konsisten dengan pola StatelessWidget.
class OrderCard extends StatelessWidget {
  final String orderId;
  final String item;
  final String quantity;
  final String status;
  final Color statusColor;
  final double progress;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.item,
    required this.quantity,
    required this.status,
    required this.statusColor,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      radius: 16,
      elevation: 4,
      surfaceColor: AppColor.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$item • $quantity',
            style: const TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColor.progressBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColor.progressFill,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

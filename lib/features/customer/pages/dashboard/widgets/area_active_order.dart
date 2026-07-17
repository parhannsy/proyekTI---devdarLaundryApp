import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';
import 'package:flutter/material.dart';

class BuildActiveOrdersSection extends StatelessWidget {
  const BuildActiveOrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _OrderMinimalCard(
            orderId: 'ORD-2024-042',
            item: 'Paket Reguler',
            quantity: '3.5 kg',
            status: 'Dicuci',
            statusColor: AppColor.info,
            progress: 0.6,
          ),
          const SizedBox(height: 10),
          _OrderMinimalCard(
            orderId: 'ORD-2024-041',
            item: 'Karpet',
            quantity: '2 pcs',
            status: 'Diterima',
            statusColor: AppColor.success,
            progress: 0.2,
          ),
        ],
      ),
    );
  }
}

class _OrderMinimalCard extends StatelessWidget {
  final String orderId;
  final String item;
  final String quantity;
  final String status;
  final Color statusColor;
  final double progress;

  const _OrderMinimalCard({
    required this.orderId,
    required this.item,
    required this.quantity,
    required this.status,
    required this.statusColor,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return MinimalCard(
      radius: 12,
      withBorder: true,
      padding: const EdgeInsets.all(14),
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
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
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
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                statusColor.withValues(alpha: 0.8),
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/dashboard/widgets/element_order_list.dart';
import 'package:flutter/material.dart';

class BuildActiveOrdersSection extends StatelessWidget {
  const BuildActiveOrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Aktif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColor.primary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const OrderCard(
            orderId: 'ORD-2024-042',
            item: 'Paket',
            quantity: '3.5 kg',
            status: 'Proses',
            statusColor: AppColor.info,
            progress: 0.6,
          ),
          const SizedBox(height: 12),
          const OrderCard(
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

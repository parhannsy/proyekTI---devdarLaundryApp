import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/order_detail_sheet.dart';

class BuildActiveOrdersSection extends StatelessWidget {
  final List<OrderModel> orders;
  final bool isLoading;

  const BuildActiveOrdersSection({
    super.key,
    required this.orders,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (isLoading && orders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _LoadingState(),
      );
    }

    // Empty state
    if (orders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _EmptyState(),
      );
    }

    // Real data
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: orders.map((order) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OrderCard(order: order),
          );
        }).toList(),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.request:
        return AppColor.warning;
      case OrderStatus.accepted:
        return AppColor.success;
      case OrderStatus.rejected:
        return AppColor.error;
      case OrderStatus.pickedUp:
      case OrderStatus.processing:
        return const Color(0xFF2196F3);
      case OrderStatus.delivering:
        return const Color(0xFFFF9800);
      case OrderStatus.completed:
        return AppColor.success;
      case OrderStatus.cancelled:
        return AppColor.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);

    return GestureDetector(
      onTap: () => OrderDetailSheet.show(context, order),
      child: MinimalCard(
        radius: 12,
        withBorder: true,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.itemName.isNotEmpty
                        ? order.itemName
                        : 'Pesanan',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${order.category.label} • ${order.quantityLabel}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColor.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: order.status.progressValue,
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  color.withValues(alpha: 0.8),
                ),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 36, color: AppColor.textMuted),
          const SizedBox(height: 8),
          const Text(
            'Belum ada pesanan aktif',
            style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Buat pesanan baru untuk memulai',
            style: TextStyle(
              fontSize: 11,
              color: AppColor.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

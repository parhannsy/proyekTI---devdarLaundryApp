import 'package:devdar_laundry_pos_app/features/customer/pages/order/models/order_models.dart';
import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';


/// 1. Top Tracker Indicator Layer
class OrderStepTracker extends StatelessWidget {
  final int currentStep;
  const OrderStepTracker({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      radius: 16,
      elevation: 3,
      surfaceColor: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Progres Order',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              bool isActive = index <= currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == currentStep ? 28 : 14,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppColor.primary : const Color(0xFFE0E6ED),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// 2. Grid Card Pilihan Kategori Layanan
class ServiceCard extends StatelessWidget {
  final ServiceCategory service;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColor.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.06 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: service.iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service.icon, color: service.iconColor, size: 26),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  service.priceInfo,
                  style: const TextStyle(fontSize: 12, color: AppColor.textSecondary),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// 3. Card Item Pilihan Diskon
class VoucherCard extends StatelessWidget {
  final DiscountVoucher voucher;
  final bool isSelected;
  final VoidCallback onTap;

  const VoucherCard({
    super.key,
    required this.voucher,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColor.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.code,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  voucher.description,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Berlaku hingga ${voucher.validUntil}',
                  style: const TextStyle(fontSize: 11, color: AppColor.textSecondary),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: voucher.badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                voucher.typeLabel,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: voucher.badgeColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// 4. Global Action Button
class OrderActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const OrderActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, color: Colors.white, size: 16),
            ]
          ],
        ),
      ),
    );
  }
}
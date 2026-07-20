import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/models/models.dart';

/// A card widget displaying a voucher/discount offer.
class DiscountCard extends StatelessWidget {
  final VoucherModel voucher;
  final bool isClaimed;
  final VoidCallback? onTap;
  final VoidCallback? onClaim;

  const DiscountCard({
    super.key,
    required this.voucher,
    this.isClaimed = false,
    this.onTap,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final usagePercent =
        voucher.totalQuota > 0 ? voucher.usedQuota / voucher.totalQuota : 0.0;
    final (Color badgeColor, IconData badgeIcon) = _badgeForType(voucher.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // ── Top section: Value + badge ──
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Discount value display
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            badgeColor.withValues(alpha: 0.15),
                            badgeColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _buildValueDisplay(badgeColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(badgeIcon,
                                        size: 10, color: badgeColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      voucher.type.label,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: badgeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isClaimed) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColor.success.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle,
                                          size: 10, color: AppColor.success),
                                      SizedBox(width: 4),
                                      Text(
                                        'Dimiliki',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: AppColor.success,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            voucher.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            voucher.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColor.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Code + quota + expiry ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    // Code chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColor.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        voucher.code,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (voucher.minimumOrder != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColor.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Min. Rp ${voucher.minimumOrder!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColor.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const Spacer(),
                    // Expiry
                    Icon(Icons.schedule_outlined,
                        size: 12, color: AppColor.textMuted),
                    const SizedBox(width: 3),
                    Text(
                      _formatDate(voucher.validUntil),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColor.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Quota progress ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Kuota:',
                          style: TextStyle(
                              fontSize: 11, color: AppColor.textSecondary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${voucher.usedQuota}/${voucher.totalQuota} digunakan',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColor.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: usagePercent,
                        backgroundColor: AppColor.progressBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          usagePercent >= 1.0
                              ? AppColor.error
                              : AppColor.primary,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Claim / Use button ──
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: isClaimed
                      ? OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Sudah Dimiliki',
                              style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.success,
                            side: const BorderSide(color: AppColor.success),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: onClaim,
                          icon: const Icon(Icons.local_offer_outlined,
                              size: 16),
                          label: const Text('Klaim Diskon',
                              style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueDisplay(Color color) {
    switch (voucher.type) {
      case VoucherType.percentage:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              voucher.value.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.0,
              ),
            ),
            Text(
              '%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: 0.7),
                height: 1.0,
              ),
            ),
          ],
        );
      case VoucherType.fixed:
        return Text(
          'Rp${voucher.value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        );
      case VoucherType.freeShipping:
        return Icon(Icons.local_shipping_outlined,
            size: 28, color: color);
    }
  }

  (Color, IconData) _badgeForType(VoucherType type) {
    switch (type) {
      case VoucherType.percentage:
        return (AppColor.primary, Icons.percent);
      case VoucherType.fixed:
        return (AppColor.success, Icons.monetization_on_outlined);
      case VoucherType.freeShipping:
        return (const Color(0xFF7B1FA2), Icons.local_shipping_outlined);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}

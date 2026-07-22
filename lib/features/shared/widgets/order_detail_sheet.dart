import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/currency_formatter.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/date_formatter.dart';

/// Status tahapan utama yang ditampilkan di tracking timeline.
/// 5 tahap: Permohonan → Diterima → Diproses → Diantar → Selesai
enum _TrackStage {
  request,
  accepted,
  processing, // pickedUp + processing
  delivering,
  completed,
}

extension _TrackStageMeta on _TrackStage {
  String get label {
    switch (this) {
      case _TrackStage.request:
        return 'Permohonan';
      case _TrackStage.accepted:
        return 'Diterima';
      case _TrackStage.processing:
        return 'Diproses';
      case _TrackStage.delivering:
        return 'Diantar';
      case _TrackStage.completed:
        return 'Selesai';
    }
  }

  IconData get icon {
    switch (this) {
      case _TrackStage.request:
        return Icons.edit_note_rounded;
      case _TrackStage.accepted:
        return Icons.check_circle_outline;
      case _TrackStage.processing:
        return Icons.local_laundry_service_outlined;
      case _TrackStage.delivering:
        return Icons.directions_car_outlined;
      case _TrackStage.completed:
        return Icons.task_alt_rounded;
    }
  }

  /// Mapping dari OrderStatus aktual ke TrackStage untuk mengetahui
  /// stage mana yang sedang aktif.
}

/// Konversi OrderStatus ke TrackStage untuk timeline.
_TrackStage _trackStageFromStatus(OrderStatus status) {
  switch (status) {
    case OrderStatus.request:
      return _TrackStage.request;
    case OrderStatus.accepted:
      return _TrackStage.accepted;
    case OrderStatus.pickedUp:
    case OrderStatus.processing:
      return _TrackStage.processing;
    case OrderStatus.delivering:
      return _TrackStage.delivering;
    case OrderStatus.completed:
      return _TrackStage.completed;
    case OrderStatus.rejected:
    case OrderStatus.cancelled:
      return _TrackStage.request; // fallback
  }
}

/// Menampilkan modal bottom sheet detail order dengan tracking timeline.
///
/// Cara pakai:
/// ```dart
/// OrderDetailSheet.show(context, order);
/// ```
class OrderDetailSheet {
  static void show(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _OrderDetailSheetContent(order: order),
    );
  }
}

class _OrderDetailSheetContent extends StatelessWidget {
  final OrderModel order;
  const _OrderDetailSheetContent({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'id');

    final currentStage = _trackStageFromStatus(order.status);
    final allStages = _TrackStage.values;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // ── Drag handle ────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColor.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header: item name + status ────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.itemName.isNotEmpty
                          ? order.itemName
                          : 'Pesanan',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.category.label} • ${order.quantityLabel}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      order.status.iconData,
                      size: 16,
                      color: _statusColor(order.status),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _statusColor(order.status),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Tracking Timeline ──────────────
          const Text(
            'Status Pesanan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Timeline stepper horizontal
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: allStages.asMap().entries.map((entry) {
                final index = entry.key;
                final stage = entry.value;
                final stageIdx = allStages.indexOf(stage);
                final currentIdx = allStages.indexOf(currentStage);

                final bool isCompleted = stageIdx < currentIdx;
                final bool isCurrent = stageIdx == currentIdx;
                final bool isFuture = stageIdx > currentIdx;

                return _TimelineStep(
                  stage: stage,
                  isCompleted: isCompleted,
                  isCurrent: isCurrent,
                  isFuture: isFuture,
                  isLast: index == allStages.length - 1,
                );
              }).toList(),
            ),
          ),

          if (order.status == OrderStatus.rejected &&
              order.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColor.error.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: AppColor.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      order.rejectionReason!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColor.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // ── Detail Informasi ────────────────
          const Text(
            'Detail Pesanan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          _detailRow(Icons.person_outline, 'Pelanggan', order.customerName),
          _detailRow(
              Icons.local_laundry_service_outlined, 'Kategori', order.category.label),
          _detailRow(
              Icons.inventory_2_outlined, 'Barang', order.itemName),
          _detailRow(Icons.scale_outlined, 'Jumlah', order.quantityLabel),
          _detailRow(
              Icons.calendar_today_outlined,
              'Pick Up',
              '${dateFormat.format(order.pickupDate)}${formatRelativeDate(order.pickupDate)}'),
          if (order.customerAddress.isNotEmpty)
            _detailRow(
                Icons.home_outlined, 'Alamat', order.customerAddress),
          if (order.estimatedTotal != null)
            _detailRow(
                Icons.receipt_long_outlined,
                'Estimasi Biaya',
                formatRupiah(order.estimatedTotal!)),
          // ── Diskon (jika ada) ──
          if (order.discount > 0) ...[
            _priceRow(
              originalPrice: formatRupiah(order.totalPrice),
              discountAmount: order.discount,
              finalPrice: order.finalPrice,
              voucherCode: order.voucherCode,
            ),
          ] else if (order.totalPrice > 0) ...[
            _detailRow(
                Icons.payments_outlined,
                'Total Dibayar',
                formatRupiah(order.finalPrice)),
          ],
          if (order.notes != null && order.notes!.isNotEmpty)
            _detailRow(Icons.notes_outlined, 'Catatan', order.notes!),

          const SizedBox(height: 20),

          // ── Tombol Tutup ────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Tutup'),
            ),
          ),
        ],
      ),
    );
  }

  /// Row khusus untuk menampilkan harga dengan coretan merah + harga baru hijau.
  Widget _priceRow({
    required String originalPrice,
    required double discountAmount,
    required double finalPrice,
    String? voucherCode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.error.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColor.error.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            // Harga asli (merah, dicoret)
            Row(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 16, color: AppColor.textSecondary),
                const SizedBox(width: 8),
                const Text(
                  'Estimasi Biaya',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  originalPrice,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.error,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColor.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Diskon
            Row(
              children: [
                Icon(Icons.local_offer_rounded,
                    size: 14, color: AppColor.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    voucherCode != null
                        ? 'Diskon $voucherCode'
                        : 'Potongan Diskon',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColor.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '-${formatRupiah(discountAmount)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColor.error,
                  ),
                ),
              ],
            ),
            const Divider(height: 12),
            // Harga final (hijau, bold)
            Row(
              children: [
                Icon(Icons.payments_outlined,
                    size: 16, color: AppColor.success),
                const SizedBox(width: 8),
                const Text(
                  'Total Dibayar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  formatRupiah(finalPrice),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColor.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColor.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColor.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}

// ─── Timeline Step Widget ─────────────────────────────────────

class _TimelineStep extends StatelessWidget {
  final _TrackStage stage;
  final bool isCompleted;
  final bool isCurrent;
  final bool isFuture;
  final bool isLast;

  const _TimelineStep({
    required this.stage,
    required this.isCompleted,
    required this.isCurrent,
    required this.isFuture,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final Color circleColor;
    final Color iconColor;
    final Color textColor;
    final Color lineColor;

    if (isCompleted) {
      circleColor = const Color(0xFF616161);
      iconColor = Colors.white;
      textColor = const Color(0xFF616161);
      lineColor = const Color(0xFF616161);
    } else if (isCurrent) {
      circleColor = AppColor.primary;
      iconColor = Colors.white;
      textColor = AppColor.primary;
      lineColor = AppColor.primary;
    } else {
      circleColor = const Color(0xFFE0E0E0);
      iconColor = const Color(0xFF9E9E9E);
      textColor = const Color(0xFF9E9E9E);
      lineColor = const Color(0xFFE0E0E0);
    }

    const double circleSize = 36;
    const double lineWidth = 48;

    // Lebar total: circle + line (kecuali step terakhir)
    final double stepWidth = circleSize + (isLast ? 0 : lineWidth);

    return SizedBox(
      width: stepWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Stack: lingkaran + garis penghubung di belakang
          SizedBox(
            width: stepWidth,
            height: circleSize,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Garis — dari tengah lingkaran, menembus sampai tengah lingkaran berikutnya
                if (!isLast)
                  Positioned(
                    left: circleSize / 2,
                    right: -(circleSize / 2),
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: lineColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                // Lingkaran
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColor.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    stage.icon,
                    size: 18,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Label — bungkus SizedBox biar wrapping bisa center sempurna
          SizedBox(
            width: stepWidth,
            child: Text(
              stage.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

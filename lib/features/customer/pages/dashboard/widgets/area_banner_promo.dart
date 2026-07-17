import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';

class BuildPromoBanners extends StatelessWidget {
  const BuildPromoBanners({super.key});

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 140;
    return SizedBox(
      height: cardHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _PromoCard(width: 240, height: cardHeight, title: 'Diskon 20% untuk Order Pertama!', subtitle: 'Gunakan kode WELCOME20', color: AppColor.primary),
          const SizedBox(width: 10),
          _PromoCard(width: 240, height: cardHeight, title: 'Voucher Gratis Ongkir Hingga 5km', subtitle: 'Berlaku untuk semua layanan', color: const Color(0xFF7B1FA2)),
          const SizedBox(width: 10),
          _PromoCard(width: 200, height: cardHeight, title: 'Gratis Cuci Sepatu', subtitle: 'Min. order 5kg', color: AppColor.success),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final double width, height;
  final String title, subtitle;
  final Color color;
  const _PromoCard({required this.width, required this.height, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return MinimalCard(
      radius: 14, withBorder: false, withShadow: true,
      width: width, height: height, padding: const EdgeInsets.all(16),
      backgroundColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: const Text('Klaim Sekarang', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
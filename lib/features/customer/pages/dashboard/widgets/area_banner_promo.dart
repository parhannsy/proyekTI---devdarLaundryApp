import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';
import 'package:flutter/material.dart';

class BuildPromoBanners extends StatelessWidget {
  const BuildPromoBanners({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita patok tinggi seragam agar layout rapi dan konsisten
    const double cardHeight = 140; 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(), // Tambahan agar scroll terasa premium
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPromoCard(
              width: 220,
              height: cardHeight,
              title: 'Diskon 20% untuk Order Pertama!',
              subtitle: 'Gunakan kode WELCOME20',
              gradient: const LinearGradient(
                colors: [AppColor.primary, AppColor.primaryDark],
              ),
            ),
            const SizedBox(width: 12),
            _buildPromoCard(
              width: 220,
              height: cardHeight,
              title: 'Voucher Gratis Ongkir Hingga 5km',
              subtitle: 'Berlaku untuk semua layanan',
              gradient: const LinearGradient(
                colors: [AppColor.primary, AppColor.primaryDark],
              ),
            ),
            const SizedBox(width: 12),
            _buildPromoCard(
              width: 180,
              height: cardHeight,
              title: 'Gratis Cuci Sepatu',
              subtitle: 'Min. order 5kg',
              color: AppColor.promoGreen,
            ),
          ],
        ),
      ),
    );
  }

  // Refactoring: Pisahkan widget card agar kode tidak duplikat (DRY)
  Widget _buildPromoCard({
    required double width,
    required double height,
    required String title,
    required String subtitle,
    Gradient? gradient,
    Color? color,
  }) {
    return ClayContainer(
      radius: 16,
      elevation: 4,
      surfaceColor: color ?? AppColor.surface,
      gradient: gradient,
      padding: const EdgeInsets.all(16),
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2, // Mencegah teks meluap jika terlalu panjang
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const Spacer(), // KUNCI: Memaksa tombol klaim berada di paling bawah
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Klaim Sekarang',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
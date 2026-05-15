import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:flutter/material.dart';

class BuildQuickActions extends StatelessWidget {
  const BuildQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk menu cepat
    final actions = [
      {
        'icon': Icons.add_circle_outline, 
        'label': 'Order Baru', 
        'color': AppColor.primary
      },
      {
        'icon': Icons.history, 
        'label': 'Riwayat', 
        'color': AppColor.primary
      },
      {
        'icon': Icons.confirmation_number_outlined, 
        'label': 'Diskon Saya', 
        'color': AppColor.success
      },
      {
        'icon': Icons.people_outline, 
        'label': 'Afiliasi', 
        'color': AppColor.primary
      },
    ];

    return Padding(
      // Menggunakan padding top kecil (misal: 12) untuk memberi napas dengan TopBar
      // tanpa membuat gap yang aneh seperti penggunaan Transform.translate
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        // Penting: agar tidak konflik dengan scroll CustomScrollView utama
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, 
          crossAxisSpacing: 12, // Dikurangi sedikit agar lebih rapat dan pas di layar kecil
          mainAxisSpacing: 12,
          childAspectRatio: 0.9, // Disesuaikan agar teks di bawah ikon tidak terpotong
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          
          return InkWell(
            onTap: () {
              // TODO: Implementasi navigasi ke masing-masing menu
              debugPrint('Menu ${action['label']} diklik');
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
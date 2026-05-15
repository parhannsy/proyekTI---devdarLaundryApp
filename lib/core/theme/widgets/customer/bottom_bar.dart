import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';

class FloatingBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static final List<String> _labels = ['Home', 'Order', 'Misi', 'Profil'];
  static final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.inventory_2_outlined,
    Icons.track_changes_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 85, // Tinggi disesuaikan agar proporsional dengan box aktif yang lebih lebar
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_labels.length, (index) {
          final isSelected = currentIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // Lebar statis agar bg primary konsisten di semua halaman
              width: 75, 
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _icons[index],
                    color: isSelected ? Colors.white : AppColor.iconSecondary,
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _labels[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColor.iconSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
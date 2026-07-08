import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:devdar_laundry_pos_app/core/router/app_router.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';

/// Shell scaffold untuk semua halaman customer.
/// Menyediakan FloatingTopbar dan FloatingBottomBar yang persistent.
class CustomerScaffold extends StatelessWidget {
  final Widget child;

  const CustomerScaffold({super.key, required this.child});

  static final _routes = [
    AppRoutes.customerDashboard,
    AppRoutes.customerOrders,
    AppRoutes.customerMissions,
    AppRoutes.customerProfile,
  ];

  static final _icons = [
    Icons.home_outlined,
    Icons.inventory_2_outlined,
    Icons.track_changes_outlined,
    Icons.person_outline,
  ];

  static final _labels = ['Home', 'Order', 'Misi', 'Profil'];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _routes.indexWhere((r) => location.startsWith(r));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final width = MediaQuery.of(context).size.width;

    // Di layar lebar (tablet/desktop), customer side juga tampil lebih rapi
    // dengan konten terpusat dan bottom bar yang menyesuaikan
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColor.background,
      body: width >= 768
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: child,
              ),
            )
          : child,
      bottomNavigationBar: _FloatingBottomBar(
        currentIndex: currentIndex,
        onTap: (index) => context.go(_routes[index]),
        icons: _icons,
        labels: _labels,
      ),
    );
  }
}

class _FloatingBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<IconData> icons;
  final List<String> labels;

  const _FloatingBottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.icons,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        height: 72,
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(labels.length, (index) {
            final isSelected = currentIndex == index;
            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                width: 72,
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
                      icons[index],
                      color: isSelected ? Colors.white : AppColor.iconSecondary,
                      size: 24,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColor.iconSecondary,
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

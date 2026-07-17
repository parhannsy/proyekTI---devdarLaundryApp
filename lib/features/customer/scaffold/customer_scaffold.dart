import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:devdar_laundry_pos_app/core/router/app_router.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';

/// Shell scaffold untuk semua halaman customer.
///
/// — Bottom bar clean, flat, minimalis
/// — Page transition slide mengikuti arah navigasi
class CustomerScaffold extends StatefulWidget {
  final Widget child;

  const CustomerScaffold({super.key, required this.child});

  @override
  State<CustomerScaffold> createState() => _CustomerScaffoldState();
}

class _CustomerScaffoldState extends State<CustomerScaffold> {
  bool _slideFromRight = true;

  static final _routes = [
    AppRoutes.customerDashboard,
    AppRoutes.customerOrders,
    AppRoutes.customerMissions,
    AppRoutes.customerProfile,
  ];

  static final _navItems = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Beranda'),
    _NavItem(Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Pesanan'),
    _NavItem(Icons.track_changes_outlined, Icons.track_changes_rounded, 'Misi'),
    _NavItem(Icons.person_outline, Icons.person_rounded, 'Profil'),
  ];

  int _currentIndex() {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _routes.indexWhere((r) => location.startsWith(r));
    return index < 0 ? 0 : index;
  }

  void _onNavigate(int targetIndex) {
    final currentIdx = _currentIndex();
    _slideFromRight = targetIndex > currentIdx;
    context.go(_routes[targetIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex();
    final width = MediaQuery.of(context).size.width;

    Widget body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final beginX = _slideFromRight ? 0.3 : -0.3;
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(beginX, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: child,
        );
      },
      child: SizedBox(
        key: ValueKey<int>(currentIndex),
        child: widget.child,
      ),
    );

    if (width >= 768) {
      body = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: body,
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColor.background,
      body: body,
      bottomNavigationBar: _MinimalBottomBar(
        currentIndex: currentIndex,
        onTap: _onNavigate,
        items: _navItems,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem(this.icon, this.activeIcon, this.label);
}

/// Bottom navigation bar minimalis — flat, clean, tanpa claymorphism.
class _MinimalBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _MinimalBottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;
            final item = items[index];

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? AppColor.primary
                              : AppColor.iconSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColor.primary
                              : AppColor.textMuted,
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

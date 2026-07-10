import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:devdar_laundry_pos_app/core/router/app_router.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';

/// Shell scaffold untuk semua halaman customer.
/// — Page transition slide sesuai arah navigasi bottom bar
/// — Bottom bar claymorphism floating dengan gliding indicator
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

  static final _icons = [
    Icons.home_outlined,
    Icons.inventory_2_outlined,
    Icons.track_changes_outlined,
    Icons.person_outline,
  ];

  static final _activeIcons = [
    Icons.home_rounded,
    Icons.inventory_2_rounded,
    Icons.track_changes_rounded,
    Icons.person_rounded,
  ];

  static final _labels = ['Home', 'Order', 'Misi', 'Profil'];

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

    // Body with page transition
    Widget body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 550),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final beginX = _slideFromRight ? 0.35 : -0.35;
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

    // Responsive
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
      bottomNavigationBar: _ClayBottomBar(
        currentIndex: currentIndex,
        onTap: _onNavigate,
        icons: _icons,
        activeIcons: _activeIcons,
        labels: _labels,
      ),
    );
  }
}

/// Bottom navigation bar claymorphism — floating dengan gliding indicator pill
class _ClayBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<IconData> icons;
  final List<IconData> activeIcons;
  final List<String> labels;

  const _ClayBottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.icons,
    required this.activeIcons,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: ClayContainer(
          radius: 28,
          elevation: 8,
          surfaceColor: AppColor.surface,
          padding: EdgeInsets.zero,
          height: 72,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final tabWidth = barWidth / labels.length;
              const pillWidth = 64.0;
              final pillLeft = (tabWidth * currentIndex + (tabWidth - pillWidth) / 2)
                  .clamp(4.0, barWidth - pillWidth - 4);

              return Stack(
                children: [
                  // ── Gliding indicator pill (claymorphism) ───
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    left: pillLeft,
                    top: 6,
                    bottom: 6,
                    width: pillWidth,
                    child: ClayContainer(
                      radius: 20,
                      elevation: 4,
                      pressed: false,
                      surfaceColor: AppColor.primary,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColor.primary, AppColor.primaryDark],
                      ),
                      padding: EdgeInsets.zero,
                      child: null,
                    ),
                  ),

                  // ── Tab items ─────────────────────────────────
                  Row(
                    children: List.generate(labels.length, (index) {
                      final isSelected = currentIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(index),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected
                                      ? activeIcons[index]
                                      : icons[index],
                                  color: isSelected
                                      ? Colors.white
                                      : AppColor.iconSecondary,
                                  size: 24,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  labels[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColor.iconSecondary,
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

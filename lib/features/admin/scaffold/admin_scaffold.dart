import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:devdar_laundry_pos_app/core/router/app_router.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/core/providers/order_provider.dart';

// Breakpoints
const double _kMobileBreak = 600;
const double _kTabletBreak = 900;

class _NavItem {
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

const _navItems = [
  _NavItem(
    route: AppRoutes.adminDashboard,
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard_rounded,
    label: 'Dashboard',
  ),
  _NavItem(
    route: AppRoutes.adminOrders,
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2_rounded,
    label: 'Pesanan',
  ),
  _NavItem(
    route: AppRoutes.adminVouchers,
    icon: Icons.confirmation_number_outlined,
    selectedIcon: Icons.confirmation_number_rounded,
    label: 'Voucher',
  ),
  _NavItem(
    route: AppRoutes.adminMissions,
    icon: Icons.track_changes_outlined,
    selectedIcon: Icons.track_changes_rounded,
    label: 'Misi',
  ),
  _NavItem(
    route: AppRoutes.adminCustomers,
    icon: Icons.people_outline,
    selectedIcon: Icons.people_rounded,
    label: 'Pelanggan',
  ),
  _NavItem(
    route: AppRoutes.adminReports,
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart_rounded,
    label: 'Laporan',
  ),
  _NavItem(
    route: AppRoutes.adminSettings,
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'Pengaturan',
  ),
];

/// Responsif admin scaffold:
/// - Mobile (<600): Drawer
/// - Tablet (600–900): NavigationRail (collapsed)
/// - Desktop (>900): Sidebar permanen dengan label
class AdminScaffold extends StatelessWidget {
  final Widget child;

  const AdminScaffold({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final i = _navItems.indexWhere((n) => loc.startsWith(n.route));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= _kTabletBreak) {
      return _DesktopAdminScaffold(
        selectedIndex: _selectedIndex(context),
        child: child,
      );
    } else if (width >= _kMobileBreak) {
      return _TabletAdminScaffold(
        selectedIndex: _selectedIndex(context),
        child: child,
      );
    } else {
      return _MobileAdminScaffold(
        selectedIndex: _selectedIndex(context),
        child: child,
      );
    }
  }
}

// ─── Mobile: AppBar + Drawer ───────────────────────────────────────────────────

class _MobileAdminScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  const _MobileAdminScaffold({
    required this.child,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: _AdminAppBar(showDrawerButton: true),
      drawer: _AdminDrawer(selectedIndex: selectedIndex),
      body: child,
    );
  }
}

// ─── Tablet: NavigationRail (collapsed) ────────────────────────────────────────

class _TabletAdminScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  const _TabletAdminScaffold({
    required this.child,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: _AdminAppBar(showDrawerButton: false),
      body: Row(
        children: [
          SingleChildScrollView(
            child: _AdminRail(selectedIndex: selectedIndex, extended: false),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ─── Desktop: Sidebar permanen ─────────────────────────────────────────────────

class _DesktopAdminScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  const _DesktopAdminScaffold({
    required this.child,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Row(
        children: [
          _AdminSidebar(selectedIndex: selectedIndex),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ─── AppBar ────────────────────────────────────────────────────────────────────

class _AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showDrawerButton;
  const _AdminAppBar({required this.showDrawerButton});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return AppBar(
      backgroundColor: AppColor.primary,
      elevation: 0,
      leading: showDrawerButton
          ? Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )
          : null,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Devdara Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: PopupMenuButton<String>(
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'profile', child: Text('Profil')),
              const PopupMenuItem(value: 'logout', child: Text('Keluar')),
            ],
            onSelected: (val) {
              if (val == 'logout') {
                _confirmLogout(context, auth);
              } else if (val == 'profile') {
                context.go(AppRoutes.adminSettings);
              }
            },
          ),
        ),
      ],
    );
  }
}

// ─── Drawer (Mobile) ───────────────────────────────────────────────────────────

class _AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  const _AdminDrawer({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Drawer(
      child: Container(
        color: const Color(0xFF1A237E),
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerHeader(context),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _navItems.length,
                  itemBuilder: (_, i) => _DrawerNavItem(
                    item: _navItems[i],
                    isSelected: selectedIndex == i,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(_navItems[i].route);
                    },
                  ),
                ),
              ),
              _buildLogoutTile(context, auth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Devdara',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Admin Panel',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: InkWell(
        onTap: () => _confirmLogout(context, auth),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: Colors.redAccent, size: 18),
              SizedBox(width: 8),
              Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _confirmLogout(BuildContext context, AuthProvider auth) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Keluar?'),
      content: const Text('Anda akan keluar dari sesi admin.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              context.read<OrderProvider>().stopListening();
              context.go('/');
              auth.logout();
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.error),
          child: const Text('Keluar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

class _DrawerNavItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                color: isSelected ? Colors.white : Colors.white54,
                size: 20,
              ),
              const SizedBox(width: 14),
              Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── NavigationRail (Tablet) ───────────────────────────────────────────────────

class _AdminRail extends StatelessWidget {
  final int selectedIndex;
  final bool extended;

  const _AdminRail({required this.selectedIndex, required this.extended});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: const Color(0xFF1A237E),
      selectedIndex: selectedIndex,
      extended: extended,
      useIndicator: true,
      indicatorColor: Colors.white.withValues(alpha: 0.15),
      selectedIconTheme: const IconThemeData(color: Colors.white),
      unselectedIconTheme: const IconThemeData(color: Colors.white54),
      selectedLabelTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.water_drop_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      destinations: _navItems
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: Text(item.label),
            ),
          )
          .toList(),
      onDestinationSelected: (i) => context.go(_navItems[i].route),
    );
  }
}

// ─── Sidebar permanen (Desktop) ────────────────────────────────────────────────

class _AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  const _AdminSidebar({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    return Container(
      width: 240,
      color: const Color(0xFF1A237E),
      child: SafeArea(
        child: Column(
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.water_drop_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Devdara',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Admin Panel',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: Colors.white.withValues(alpha: 0.1),
                height: 1,
              ),
            ),
            const SizedBox(height: 8),

            // Nav items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _navItems.length,
                itemBuilder: (_, i) => _DrawerNavItem(
                  item: _navItems[i],
                  isSelected: selectedIndex == i,
                  onTap: () => context.go(_navItems[i].route),
                ),
              ),
            ),

            // User card + logout
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    color: Colors.white.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user?.name ?? 'Admin',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Administrator',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                        onPressed: () => _confirmLogout(context, auth),
                        tooltip: 'Keluar',
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

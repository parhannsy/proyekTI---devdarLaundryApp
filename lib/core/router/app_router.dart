import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../models/user_model.dart';

import '../../features/auth/login_page.dart';
import '../../features/customer/overlay/welcome_splash.dart';
import '../../features/customer/scaffold/customer_scaffold.dart';
import '../../features/customer/pages/dashboard/index.dart';
import '../../features/customer/pages/order/index.dart';
import '../../features/customer/pages/mission/index.dart';
import '../../features/customer/pages/profil/index.dart';
import '../../features/admin/scaffold/admin_scaffold.dart';
import '../../features/admin/pages/dashboard/admin_dashboard_page.dart';
import '../../features/admin/pages/orders/admin_order_page.dart';
import '../../features/admin/pages/vouchers/admin_voucher_page.dart';
import '../../features/admin/pages/missions/admin_mission_page.dart';
import '../../features/admin/pages/customers/admin_customer_page.dart';
import '../../features/admin/pages/reports/admin_report_page.dart';
import '../../features/admin/pages/settings/admin_settings_page.dart';

class AppRoutes {
  static const login = '/';
  static const welcomeSplash = '/welcome';
  static const customerDashboard = '/customer/dashboard';
  static const customerOrders = '/customer/orders';
  static const customerMissions = '/customer/missions';
  static const customerProfile = '/customer/profile';
  static const adminDashboard = '/admin/dashboard';
  static const adminOrders = '/admin/orders';
  static const adminVouchers = '/admin/vouchers';
  static const adminMissions = '/admin/missions';
  static const adminCustomers = '/admin/customers';
  static const adminReports = '/admin/reports';
  static const adminSettings = '/admin/settings';
}

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: AppRoutes.login,
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final status = authProvider.status;
        final location = state.matchedLocation;

        // Masih loading — jangan redirect
        if (status == AuthStatus.initial || status == AuthStatus.loading) {
          return null;
        }

        final isOnAuth =
            location == AppRoutes.login || location == AppRoutes.welcomeSplash;

        // Belum login → paksa ke login
        if (status == AuthStatus.unauthenticated ||
            status == AuthStatus.error) {
          return isOnAuth ? null : AppRoutes.login;
        }

        // Sudah login
        if (status == AuthStatus.authenticated) {
          final role = authProvider.currentUser?.role;

          // Admin masuk ke rute customer — tolak
          if (role == UserRole.admin && location.startsWith('/customer')) {
            return AppRoutes.adminDashboard;
          }

          // Customer masuk ke rute admin — tolak
          if (role == UserRole.customer && location.startsWith('/admin')) {
            return AppRoutes.customerDashboard;
          }
        }

        return null;
      },
      routes: [
        // ── Auth ──────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.welcomeSplash,
          name: 'welcomeSplash',
          builder: (_, __) => const WelcomeSplashPage(),
        ),

        // ── Customer (Shell) ───────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => CustomerScaffold(child: child),
          routes: [
            GoRoute(
              path: '/customer',
              redirect: (_, __) => AppRoutes.customerDashboard,
              builder: (_, __) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: AppRoutes.customerDashboard,
              name: 'customerDashboard',
              builder: (_, __) => const HomePage(),
            ),
            GoRoute(
              path: AppRoutes.customerOrders,
              name: 'customerOrders',
              builder: (_, __) => const OrderPage(),
            ),
            GoRoute(
              path: AppRoutes.customerMissions,
              name: 'customerMissions',
              builder: (_, __) => const MissionPage(),
            ),
            GoRoute(
              path: AppRoutes.customerProfile,
              name: 'customerProfile',
              builder: (_, __) => const ProfilePage(),
            ),
          ],
        ),

        // ── Admin (Shell) ──────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => AdminScaffold(child: child),
          routes: [
            GoRoute(
              path: '/admin',
              redirect: (_, __) => AppRoutes.adminDashboard,
              builder: (_, __) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: AppRoutes.adminDashboard,
              name: 'adminDashboard',
              builder: (_, __) => const AdminDashboardPage(),
            ),
            GoRoute(
              path: AppRoutes.adminOrders,
              name: 'adminOrders',
              builder: (_, __) => const AdminOrderPage(),
            ),
            GoRoute(
              path: AppRoutes.adminVouchers,
              name: 'adminVouchers',
              builder: (_, __) => const AdminVoucherPage(),
            ),
            GoRoute(
              path: AppRoutes.adminMissions,
              name: 'adminMissions',
              builder: (_, __) => const AdminMissionPage(),
            ),
            GoRoute(
              path: AppRoutes.adminCustomers,
              name: 'adminCustomers',
              builder: (_, __) => const AdminCustomerPage(),
            ),
            GoRoute(
              path: AppRoutes.adminReports,
              name: 'adminReports',
              builder: (_, __) => const AdminReportPage(),
            ),
            GoRoute(
              path: AppRoutes.adminSettings,
              name: 'adminSettings',
              builder: (_, __) => const AdminSettingsPage(),
            ),
          ],
        ),
      ],
    );
  }
}

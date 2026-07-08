import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/providers/providers.dart';
import 'core/data/mock_data.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Mengunci orientasi agar konsisten di semua device
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Status bar transparan agar tampilan header lebih imersif
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const DevdaraApp());
}

class DevdaraApp extends StatelessWidget {
  const DevdaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Dependency injection via MultiProvider ────────────────────────────────
    // Urutan: repository (mock) → provider yang bergantung pada repository
    return MultiProvider(
      providers: [
        // Auth
        ChangeNotifierProvider(
          create: (_) => AuthProvider(MockAuthRepository()),
        ),
        // Order
        ChangeNotifierProvider(
          create: (_) => OrderProvider(MockOrderRepository()),
        ),
        // Voucher
        ChangeNotifierProvider(
          create: (_) => VoucherProvider(MockVoucherRepository()),
        ),
        // Mission
        ChangeNotifierProvider(
          create: (_) => MissionProvider(MockMissionRepository()),
        ),
        // Customer
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(MockCustomerRepository()),
        ),
        // Report
        ChangeNotifierProvider(
          create: (_) => ReportProvider(MockReportRepository()),
        ),
      ],
      child: const _RouterRoot(),
    );
  }
}

/// Memisahkan router ke widget tersendiri agar bisa mengakses AuthProvider
/// yang sudah di-inject oleh MultiProvider di atas.
class _RouterRoot extends StatefulWidget {
  const _RouterRoot();

  @override
  State<_RouterRoot> createState() => _RouterRootState();
}

class _RouterRootState extends State<_RouterRoot> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Router dibuat sekali dan menyimpan referensi ke AuthProvider
    final auth = context.read<AuthProvider>();
    _router = AppRouter.createRouter(auth);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Devdara Laundry',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────────────
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        primaryColor: const Color(0xFF2196F3),
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
        fontFamily: 'Roboto',
        useMaterial3: true,

        // AppBar global
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),

        // Card global
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),

        // Input global
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F9FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),

        // ElevatedButton global
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // TabBar
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
        ),
      ),

      // ── Router ─────────────────────────────────────────────────────────────
      routerConfig: _router,
    );
  }
}

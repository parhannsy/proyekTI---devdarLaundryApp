import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'core/providers/providers.dart';
import 'core/data/firebase/firebase_data.dart';
import 'core/data/firebase/seed_service.dart';
import 'core/data/mock_data.dart';
import 'core/router/app_router.dart';
import 'core/repositories/repositories.dart';
import 'core/services/notification_service.dart';

/// Flag global — apakah Firebase berhasil diinisialisasi?
/// Di web selalu false karena Firebase JS SDK tidak di-load.
bool firebaseAvailable = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Inisialisasi Locale Indonesia (untuk DateFormat & NumberFormat) ──
  try {
    await initializeDateFormatting('id', null);
    debugPrint('[Main] 📅 Locale id berhasil diinisialisasi.');
  } catch (e) {
    debugPrint('[Main] ⚠️ Gagal init locale id: $e');
  }

  // ── Inisialisasi Firebase ───────────────────────────────────
  // Coba init Firebase di semua platform (mobile + web).
  // Kalau gagal (misal koneksi jelek atau web JS SDK error),
  // fallback otomatis ke Mock data tanpa mengganggu user.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    await SeedService.seedIfNeeded()
        .timeout(const Duration(seconds: 10));
    firebaseAvailable = true;
    debugPrint('[Main] ✅ Firebase berhasil diinisialisasi.');
  } on TimeoutException {
    debugPrint('[Main] ⏱️ Firebase init timeout — fallback ke Mock Data.');
  } catch (e) {
    debugPrint('[Main] ⚠️ Firebase gagal init — fallback ke Mock Data.');
    debugPrint('[Main] Detail error: $e');
  }

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

  // ── Inisialisasi Notifikasi Lokal ───────────────────────
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('[Main] ⚠️ Gagal init notifikasi: $e');
  }

  runApp(const DevdaraApp());
}

/// Memilih repository berdasarkan ketersediaan Firebase.
AuthRepository _pickAuthRepository() =>
    firebaseAvailable ? FirebaseAuthRepository() : MockAuthRepository();
OrderRepository _pickOrderRepository() =>
    firebaseAvailable ? FirebaseOrderRepository() : MockOrderRepository();
VoucherRepository _pickVoucherRepository() =>
    firebaseAvailable ? FirebaseVoucherRepository() : MockVoucherRepository();
MissionRepository _pickMissionRepository() =>
    firebaseAvailable ? FirebaseMissionRepository() : MockMissionRepository();
CustomerRepository _pickCustomerRepository() =>
    firebaseAvailable ? FirebaseCustomerRepository() : MockCustomerRepository();
ReportRepository _pickReportRepository() =>
    firebaseAvailable ? FirebaseReportRepository() : MockReportRepository();

class DevdaraApp extends StatelessWidget {
  const DevdaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Dependency injection via MultiProvider ────────────────────────────────
    return MultiProvider(
      providers: [
        // Auth
        ChangeNotifierProvider(
          create: (_) => AuthProvider(_pickAuthRepository()),
        ),
        // Order
        ChangeNotifierProvider(
          create: (_) => OrderProvider(_pickOrderRepository()),
        ),
        // Voucher
        ChangeNotifierProvider(
          create: (_) => VoucherProvider(_pickVoucherRepository()),
        ),
        // Mission
        ChangeNotifierProvider(
          create: (_) => MissionProvider(_pickMissionRepository()),
        ),
        // Customer
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(_pickCustomerRepository()),
        ),
        // Report
        ChangeNotifierProvider(
          create: (_) => ReportProvider(_pickReportRepository()),
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

      // ── Lokalisasi (untuk date picker dll) ────────────────────────────────
      locale: const Locale('id'),
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Router ─────────────────────────────────────────────────────────────
      routerConfig: _router,
    );
  }
}

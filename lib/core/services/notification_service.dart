import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service untuk menampilkan notifikasi lokal di handphone.
///
/// Bekerja tanpa FCM — cukup trigger dari Firestore stream yang sudah ada.
/// Notifikasi muncul di notification bar ketika app di foreground/background.
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Inisialisasi plugin notifikasi (panggil sekali di awal app).
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Android: channel + icon default
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS: request izin
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _initialized = true;
      debugPrint('[NotificationService] ✅ Berhasil diinisialisasi');
    } catch (e) {
      debugPrint('[NotificationService] ⚠️ Gagal init: $e');
    }
  }

  /// Callback ketika notifikasi di-tap.
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('[NotificationService] Notifikasi di-tap: ${response.payload}');
    // TODO: navigasi ke halaman orders jika diperlukan
  }

  /// Tampilkan notifikasi permohonan order baru di notification bar.
  Future<void> showNewOrderNotification({required int count}) async {
    if (!_initialized) await initialize();

    try {
      // ID unik berdasarkan waktu (dalam detik)
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const androidDetails = AndroidNotificationDetails(
        'new_orders',
        'Permohonan Baru',
        channelDescription: 'Notifikasi ketika ada permohonan order baru masuk',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final title = count == 1 ? '1 Permohonan Baru' : '$count Permohonan Baru';
      final body = count == 1
          ? '1 permohonan order masuk, segera ambil tindakan'
          : '$count permohonan order masuk, segera ambil tindakan';

      await _plugin.show(
        id,
        title,
        body,
        details,
        payload: 'new_orders',
      );

      debugPrint('[NotificationService] 🔔 Notifikasi dikirim: $title');
    } catch (e) {
      debugPrint('[NotificationService] ⚠️ Gagal show notif: $e');
    }
  }
}

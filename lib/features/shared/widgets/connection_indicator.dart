import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;

import 'package:devdar_laundry_pos_app/firebase_options.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart' show AppColor;
import 'package:devdar_laundry_pos_app/main.dart' show firebaseAvailable;

/// Indicator kecil yang menunjukkan status koneksi Firebase.
///
/// 🔴 Offline Mode — app pakai Mock data
/// 🟢 Firebase Online — app konek ke Firebase beneran
///
/// Tap untuk buka dialog debug yang berisi:
/// - Status koneksi saat ini
/// - Tombol "Test Koneksi"
/// - Tombol "Coba Sambungkan Ulang" (re-init Firebase)
class ConnectionIndicator extends StatelessWidget {
  final bool compact;

  const ConnectionIndicator({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isOnline = firebaseAvailable;

    return GestureDetector(
      onTap: () => _showDebugDialog(context),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 4 : 5,
        ),
        decoration: BoxDecoration(
          color: isOnline
              ? const Color(0xFF4CAF50).withValues(alpha: 0.12)
              : const Color(0xFFE53935).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOnline
                ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                : const Color(0xFFE53935).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 6 : 8,
              height: compact ? 6 : 8,
              decoration: BoxDecoration(
                color: isOnline ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isOnline ? const Color(0xFF4CAF50) : const Color(0xFFE53935))
                        .withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            SizedBox(width: compact ? 4 : 6),
            Text(
              isOnline ? 'Firebase' : 'Offline',
              style: TextStyle(
                fontSize: compact ? 9 : 11,
                fontWeight: FontWeight.w600,
                color: isOnline ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                letterSpacing: 0.3,
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.info_outline,
                size: 12,
                color: isOnline
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.6)
                    : const Color(0xFFE53935).withValues(alpha: 0.6),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDebugDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _ConnectionDebugDialog(),
    );
  }
}

// ── Debug Dialog ──────────────────────────────────────────────────────────────

class _ConnectionDebugDialog extends StatefulWidget {
  const _ConnectionDebugDialog();

  @override
  State<_ConnectionDebugDialog> createState() => _ConnectionDebugDialogState();
}

class _ConnectionDebugDialogState extends State<_ConnectionDebugDialog> {
  bool _isTesting = false;
  bool _isReinitializing = false;
  String? _testResult;

  @override
  Widget build(BuildContext context) {
    final isOnline = firebaseAvailable;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                  : const Color(0xFFE53935).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              color: isOnline ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Koneksi Database',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.08)
                  : const Color(0xFFE53935).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isOnline
                      ? 'Terhubung ke Firebase 🔥'
                      : 'Mode Offline — Data menggunakan Mock 🔌',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isOnline ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  ),
                ),
              ],
            ),
          ),

          if (!isOnline) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFFE65100), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Data tidak tersimpan ke database karena emulator/HP tidak terhubung ke internet atau Firebase gagal init.\n\n'
                      '💡 Cold Boot emulator (Device Manager → ▼ → Cold Boot), lalu restart aplikasi.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFBF360C), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Test result
          if (_testResult != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _testResult!.startsWith('✅')
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.08)
                      : const Color(0xFFE53935).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _testResult!,
                  style: TextStyle(
                    fontSize: 12,
                    color: _testResult!.startsWith('✅')
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                  ),
                ),
              ),
            ),

          // Buttons
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting
                  ? const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_find, size: 16),
              label: Text(_isTesting ? 'Menguji...' : 'Test Koneksi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          if (!isOnline) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isReinitializing ? null : _reinitializeFirebase,
                icon: _isReinitializing
                    ? const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh, size: 16),
                label: Text(_isReinitializing ? 'Menghubungkan...' : 'Coba Sambungkan Ulang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  Future<void> _testConnection() async {
    if (!context.mounted) return;
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      if (!context.mounted) return;
      setState(() => _testResult = '✅ Koneksi ke Firestore berhasil!');
    } on TimeoutException {
      if (!context.mounted) return;
      setState(() => _testResult = '❌ Timeout — Firestore tidak merespon dalam 5 detik.');
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _testResult = '❌ Gagal: ${e.toString().replaceFirst("Exception: ", "")}');
    } finally {
      if (context.mounted) _isTesting = false;
    }
  }

  Future<void> _reinitializeFirebase() async {
    if (!context.mounted) return;
    setState(() {
      _isReinitializing = true;
      _testResult = null;
    });

    try {
      if (firebaseAvailable) {
        if (!context.mounted) return;
        setState(() => _testResult = '✅ Firebase sudah terhubung.');
        _isReinitializing = false;
        return;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 10));

      await FirebaseFirestore.instance
          .collection('users')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));

      // Update flag global agar indikator berubah hijau
      firebaseAvailable = true;

      if (!context.mounted) return;
      setState(() {
        _testResult = '✅ Firebase berhasil terhubung!\n'
            'ℹ️ Silakan restart aplikasi agar menggunakan mode Firebase.';
      });
    } on TimeoutException {
      if (!context.mounted) return;
      setState(() => _testResult = '⏱️ Timeout — Firebase tidak bisa dijangkau.\n'
          'Coba cold boot emulator, lalu restart aplikasi.');
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('already initialized')) {
        // Firebase sudah terinit — flag belum true karena timeout sebelumnya
        firebaseAvailable = true;
        if (!context.mounted) return;
        setState(() => _testResult = '✅ Firebase sudah aktif. Coba test koneksi lagi.');
      } else {
        if (!context.mounted) return;
        setState(() => _testResult = '❌ Gagal: ${msg.replaceFirst("Exception: ", "")}');
      }
    } finally {
      if (context.mounted) _isReinitializing = false;
    }
  }
}

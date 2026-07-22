import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service untuk menyuntikkan data awal ke Firebase.
///
/// Menciptakan 2 akun demo (customer + admin) beserta dokumen Firestore-nya
/// jika belum ada user sama sekali di koleksi `users`.
class SeedService {
  static final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _customerEmail = 'customer@devdara.com';
  static const _customerPassword = 'customer123';
  static const _adminEmail = 'admin@devdara.com';
  static const _adminPassword = 'admin123';

  /// Jalankan sekali di awal app untuk mengecek dan mengisi data awal.
  static Future<void> seedIfNeeded() async {
    try {
      // Cek apakah sudah ada user di Firestore
      final existing = await _firestore.collection('users').limit(1).get();
      if (existing.docs.isNotEmpty) {
        debugPrint('[SeedService] Data sudah ada, skip seeding.');
        return;
      }

      debugPrint('[SeedService] Menyuntikkan data awal...');

      await _createUser(
        email: _customerEmail,
        password: _customerPassword,
        displayName: 'Ahmad Farhan',
        phone: '081234567890',
        role: 'customer',
        loyaltyPoints: 320,
        totalSavings: 125000,
        joinDate: DateTime(2024, 1, 15),
      );

      await _createUser(
        email: _adminEmail,
        password: _adminPassword,
        displayName: 'Admin Devdara',
        phone: '089876543210',
        role: 'admin',
        joinDate: DateTime(2023, 6, 1),
      );

      debugPrint('[SeedService] Selesai! 2 akun berhasil dibuat.');
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed') {
        debugPrint(
          '[SeedService] ⚠️ Auth Email/Password belum diaktifkan di Firebase Console. '
          'Buka Firebase Console → Authentication → Sign-in method → '
          'aktifkan Email/Password.',
        );
      } else if (e.code == 'email-already-in-use') {
        debugPrint(
          '[SeedService] ⚠️ Akun sudah ada di Auth. Sync ke Firestore...',
        );
        // Sign in untuk dapetin UID, lalu buat dokumen Firestore
        await _forceSync(email: _customerEmail, password: _customerPassword);
        await _forceSync(email: _adminEmail, password: _adminPassword);
      } else {
        debugPrint('[SeedService] Error Firebase Auth: $e');
      }
    } catch (e) {
      debugPrint('[SeedService] Error umum: $e');
    }
  }

  /// Buat user baru di Firebase Auth + Firestore.
  static Future<void> _createUser({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required String role,
    int loyaltyPoints = 0,
    int totalSavings = 0,
    required DateTime joinDate,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(cred.user!.uid).set({
      'name': displayName,
      'email': email,
      'phone': phone,
      'role': role,
      'loyaltyPoints': loyaltyPoints,
      'totalSavings': totalSavings,
      'hasSeenSplash': role == 'customer', // customer seeding skip splash
      'isProfileComplete': true,
      'addresses': role == 'customer'
          ? [{'address': 'Jl. Merdeka No. 10, Jakarta Pusat', 'label': 'Utama', 'isDefault': true}]
          : [],
      'createdAt': joinDate,
    });

    debugPrint('[SeedService] Akun $role: $email / $password');
  }

  /// Jika akun email sudah terdaftar di Auth, sign in untuk dapetin UID
  /// lalu buat dokumen Firestore-nya.
  static Future<void> _forceSync({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'name': email == _customerEmail ? 'Ahmad Farhan' : 'Admin Devdara',
        'email': email,
        'phone': email == _customerEmail ? '081234567890' : '089876543210',
        'role': email == _customerEmail ? 'customer' : 'admin',
        'hasSeenSplash': email == _customerEmail, // customer skip splash
        'isProfileComplete': true,
        'addresses': email == _customerEmail
            ? [{'address': 'Jl. Merdeka No. 10, Jakarta Pusat', 'label': 'Utama', 'isDefault': true}]
            : [],
        'loyaltyPoints': email == _customerEmail ? 320 : 0,
        'totalSavings': email == _customerEmail ? 125000 : 0,
        'createdAt': email == _customerEmail
            ? DateTime(2024, 1, 15)
            : DateTime(2023, 6, 1),
      });
      debugPrint('[SeedService] Sync Firestore untuk $email berhasil.');
    } catch (e) {
      debugPrint('[SeedService] Gagal sync $email: $e');
    }
  }
}

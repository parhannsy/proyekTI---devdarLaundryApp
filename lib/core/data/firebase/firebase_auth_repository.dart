import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';
import '../../repositories/auth_repository.dart';
import '../../../firebase_options.dart';
import 'package:flutter/foundation.dart';

/// Implementasi [AuthRepository] menggunakan Firebase Auth + Firestore.
class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = result.user!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      debugPrint('[AuthRepo] Dokumen Firestore belum ada untuk uid=$uid, membuat baru...');
      await _createUserDocument(uid: uid, email: email);
      final newDoc = await _firestore.collection('users').doc(uid).get();
      if (newDoc.exists) {
        return _userFromDoc(uid, newDoc.data()!);
      }
      throw Exception('Akun tidak ditemukan.');
    }

    return _userFromDoc(uid, doc.data()!);
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    // Gunakan REST API via http package agar tidak mengubah sesi admin.
    // createUserWithEmailAndPassword akan logout admin karena Firebase Auth
    // hanya mendukung 1 sesi aktif.
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp'
      '?key=${DefaultFirebaseOptions.android.apiKey}',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final error = body['error']?['message'] ?? 'Gagal membuat akun.';
      throw Exception(error);
    }

    final uid = body['localId'] as String;

    // Buat dokumen Firestore dengan role customer & isProfileComplete = false
    await _firestore.collection('users').doc(uid).set({
      'name': '',
      'nickname': '',
      'email': email,
      'phone': '',
      'addresses': [],
      'role': 'customer',
      'loyaltyPoints': 0,
      'totalSavings': 0,
      'avatarUrl': null,
      'hasSeenSplash': false,
      'isProfileComplete': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('[AuthRepo] Akun customer baru dibuat: $email ($uid)');

    return UserModel(
      id: uid,
      name: '',
      nickname: '',
      email: email,
      phone: '',
      addresses: [],
      role: UserRole.customer,
      createdAt: DateTime.now(),
      isProfileComplete: false,
    );
  }

  @override
  Future<void> markSplashSeen(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'hasSeenSplash': true,
    });
    debugPrint('[AuthRepo] hasSeenSplash=true untuk uid=$uid');
  }

  @override
  Future<UserModel> completeProfile({
    required String uid,
    required String name,
    required String nickname,
    required String phone,
    required String address,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'nickname': nickname,
      'phone': phone,
      'addresses': [{'address': address, 'label': 'Utama', 'isDefault': true}],
      'isProfileComplete': true,
    });

    // Baca ulang dokumen yang sudah diupdate
    final doc = await _firestore.collection('users').doc(uid).get();
    return _userFromDoc(uid, doc.data()!);
  }

  /// Membuat dokumen user di Firestore dengan data default.
  Future<void> _createUserDocument({
    required String uid,
    required String email,
  }) async {
    final isAdmin = email == 'admin@devdara.com';
    final isDemo = email.isDemoAccount;
    final displayName = isAdmin ? 'Admin Devdara' : email.split('@').first;
    final phone = isAdmin ? '089876543210' : (isDemo ? '081234567890' : '');
    final role = isAdmin ? 'admin' : 'customer';
    final loyaltyPoints = isDemo && !isAdmin ? 320 : 0;
    final totalSavings = isDemo && !isAdmin ? 125000 : 0;

    await _firestore.collection('users').doc(uid).set({
      'name': displayName,
      'nickname': isDemo ? email.split('@').first : '',
      'email': email,
      'phone': phone,
      'addresses': [],
      'role': role,
      'loyaltyPoints': loyaltyPoints,
      'totalSavings': totalSavings,
      'avatarUrl': null,
      'hasSeenSplash': !isAdmin,
      'isProfileComplete': isDemo || isAdmin,
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('[AuthRepo] Dokumen Firestore berhasil dibuat untuk $email ($role)');
  }

  @override
  Future<UserModel> updateProfile({
    required String uid,
    String? name,
    String? nickname,
    String? phone,
    String? address,
    List<AddressModel>? addresses,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (nickname != null) updates['nickname'] = nickname;
    if (phone != null) updates['phone'] = phone;
    if (addresses != null) {
      updates['addresses'] = addresses.map((a) => a.toJson()).toList();
    } else if (address != null) {
      updates['addresses'] = [{'address': address, 'label': 'Utama', 'isDefault': true}];
    }

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);
    }

    final doc = await _firestore.collection('users').doc(uid).get();
    return _userFromDoc(uid, doc.data()!);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User tidak ditemukan.');
    }

    // 1. Re-authenticate dengan password lama
    final credential = fb.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // 2. Update ke password baru (langsung, tanpa email!)
    await user.updatePassword(newPassword);

    debugPrint('[AuthRepo] Password berhasil diubah untuk ${user.email}');
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return _userFromDoc(user.uid, doc.data()!);
  }

  /// Parse addresses dari Firestore, dengan fallback ke field 'address' lama.
  List<AddressModel> _parseAddresses(Map<String, dynamic> data) {
    final list = (data['addresses'] as List<dynamic>?)
        ?.map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
        .toList();
    if (list != null && list.isNotEmpty) return list;
    // Backward compat: field 'address' String lama
    if (data['address'] != null && (data['address'] as String).isNotEmpty) {
      return [AddressModel(address: data['address'], label: 'Utama', isDefault: true)];
    }
    return [];
  }

  UserModel _userFromDoc(String uid, Map<String, dynamic> data) {
    return UserModel(
      id: uid,
      name: data['name'] ?? '',
      nickname: data['nickname'],
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      addresses: _parseAddresses(data),
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.customer,
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      totalSavings: (data['totalSavings'] ?? 0).toDouble(),
      avatarUrl: data['avatarUrl'],
      hasSeenSplash: data['hasSeenSplash'] ?? false,
      isProfileComplete: data['isProfileComplete'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

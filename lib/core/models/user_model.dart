import 'address_model.dart';

enum UserRole { customer, admin }

class UserModel {
  final String id;
  final String name;
  final String? nickname;
  final String email;
  final String phone;
  final List<AddressModel> addresses;
  final UserRole role;
  final int loyaltyPoints;
  final double totalSavings;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool hasSeenSplash;
  final bool isProfileComplete;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.nickname,
    this.addresses = const [],
    this.loyaltyPoints = 0,
    this.totalSavings = 0.0,
    this.avatarUrl,
    required this.createdAt,
    this.hasSeenSplash = false,
    this.isProfileComplete = false,
  });

  /// Alamat utama (default). Jika tidak ada yang default, ambil yang pertama.
  AddressModel? get defaultAddress {
    if (addresses.isEmpty) return null;
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.first;
    }
  }

  /// Nama depan alamat default (untuk kompatibilitas).
  String? get address => defaultAddress?.address;

  UserModel copyWith({
    String? id,
    String? name,
    String? nickname,
    String? email,
    String? phone,
    List<AddressModel>? addresses,
    UserRole? role,
    int? loyaltyPoints,
    double? totalSavings,
    String? avatarUrl,
    DateTime? createdAt,
    bool? hasSeenSplash,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addresses: addresses ?? this.addresses,
      role: role ?? this.role,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      totalSavings: totalSavings ?? this.totalSavings,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      hasSeenSplash: hasSeenSplash ?? this.hasSeenSplash,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}

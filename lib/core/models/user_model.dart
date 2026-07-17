enum UserRole { customer, admin }

class UserModel {
  final String id;
  final String name;
  final String? nickname;
  final String email;
  final String phone;
  final String? address;
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
    this.address,
    this.loyaltyPoints = 0,
    this.totalSavings = 0.0,
    this.avatarUrl,
    required this.createdAt,
    this.hasSeenSplash = false,
    this.isProfileComplete = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? nickname,
    String? email,
    String? phone,
    String? address,
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
      address: address ?? this.address,
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

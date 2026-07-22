/// Model untuk alamat yang bisa dimiliki user.
///
/// Setiap user bisa punya beberapa alamat (rumah, kantor, dll).
/// Satu alamat bisa ditandai sebagai default.
class AddressModel {
  final String address;
  final String? label; // "Rumah", "Kantor", "Sekolah", dll.
  final bool isDefault;

  const AddressModel({
    required this.address,
    this.label,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? address,
    String? label,
    bool? isDefault,
  }) {
    return AddressModel(
      address: address ?? this.address,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// Nama label yang ditampilkan di UI.
  /// Jika label ada, tampilkan "🏠 Rumah", jika tidak "Alamat".
  String get displayLabel => label ?? 'Alamat';

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'label': label,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      address: json['address'] ?? '',
      label: json['label'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}

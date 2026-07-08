enum VoucherType { percentage, fixed, freeShipping }
enum VoucherStatus { active, expired, used }

extension VoucherTypeLabel on VoucherType {
  String get label {
    switch (this) {
      case VoucherType.percentage:
        return 'Persen';
      case VoucherType.fixed:
        return 'Nominal';
      case VoucherType.freeShipping:
        return 'Gratis Ongkir';
    }
  }
}

class VoucherModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final VoucherType type;
  final double value;
  final double? minimumOrder;
  final int totalQuota;
  final int usedQuota;
  final DateTime validFrom;
  final DateTime validUntil;
  final VoucherStatus status;
  final bool isPublic;

  const VoucherModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.minimumOrder,
    required this.totalQuota,
    this.usedQuota = 0,
    required this.validFrom,
    required this.validUntil,
    this.status = VoucherStatus.active,
    this.isPublic = true,
  });

  int get remainingQuota => totalQuota - usedQuota;
  bool get isExpired => DateTime.now().isAfter(validUntil);
  bool get isFull => usedQuota >= totalQuota;
  bool get isAvailable => !isExpired && !isFull && status == VoucherStatus.active;

  String get valueDisplay {
    switch (type) {
      case VoucherType.percentage:
        return '${value.toStringAsFixed(0)}%';
      case VoucherType.fixed:
        return 'Rp ${value.toStringAsFixed(0)}';
      case VoucherType.freeShipping:
        return 'Gratis Ongkir';
    }
  }

  VoucherModel copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    VoucherType? type,
    double? value,
    double? minimumOrder,
    int? totalQuota,
    int? usedQuota,
    DateTime? validFrom,
    DateTime? validUntil,
    VoucherStatus? status,
    bool? isPublic,
  }) {
    return VoucherModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      totalQuota: totalQuota ?? this.totalQuota,
      usedQuota: usedQuota ?? this.usedQuota,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}

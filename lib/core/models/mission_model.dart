enum MissionStatus { active, completed, expired, locked }
enum MissionType { orderCount, orderAmount, referral, firstOrder, loyalty }

extension MissionTypeLabel on MissionType {
  String get label {
    switch (this) {
      case MissionType.orderCount:
        return 'Jumlah Order';
      case MissionType.orderAmount:
        return 'Nilai Order';
      case MissionType.referral:
        return 'Referral';
      case MissionType.firstOrder:
        return 'Order Pertama';
      case MissionType.loyalty:
        return 'Loyalitas';
    }
  }
}

class MissionReward {
  final String description;
  final double? discountValue;
  final bool? isFreeItem;
  final int? bonusPoints;

  const MissionReward({
    required this.description,
    this.discountValue,
    this.isFreeItem,
    this.bonusPoints,
  });
}

class MissionModel {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int targetValue;
  final MissionReward reward;
  final DateTime? validUntil;
  final bool isActive;

  const MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.reward,
    this.validUntil,
    this.isActive = true,
  });

  MissionModel copyWith({
    String? id,
    String? title,
    String? description,
    MissionType? type,
    int? targetValue,
    MissionReward? reward,
    DateTime? validUntil,
    bool? isActive,
  }) {
    return MissionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      reward: reward ?? this.reward,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Progress misi milik seorang customer
class CustomerMissionProgress {
  final String missionId;
  final String customerId;
  final int currentValue;
  final MissionStatus status;
  final DateTime? completedAt;

  const CustomerMissionProgress({
    required this.missionId,
    required this.customerId,
    required this.currentValue,
    required this.status,
    this.completedAt,
  });
}

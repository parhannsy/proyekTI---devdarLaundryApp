import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';
import '../../repositories/mission_repository.dart';

/// Implementasi [MissionRepository] menggunakan Cloud Firestore.
class FirebaseMissionRepository implements MissionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _missions => _firestore.collection('missions');
  CollectionReference get _progress =>
      _firestore.collection('mission_progress');

  @override
  Future<List<MissionModel>> getAllMissions() async {
    final snapshot = await _missions.get();
    return snapshot.docs.map((doc) => _missionFromDoc(doc)).toList();
  }

  @override
  Future<List<MissionModel>> getActiveMissions() async {
    final snapshot = await _missions
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => _missionFromDoc(doc)).toList();
  }

  @override
  Future<MissionModel> createMission(MissionModel mission) async {
    final docRef = _missions.doc();
    await docRef.set(_missionToDoc(mission.copyWith(id: docRef.id)));
    return mission.copyWith(id: docRef.id);
  }

  @override
  Future<MissionModel> updateMission(MissionModel mission) async {
    await _missions.doc(mission.id).update(_missionToDoc(mission));
    return mission;
  }

  @override
  Future<void> deleteMission(String id) async {
    await _missions.doc(id).delete();
  }

  @override
  Future<List<CustomerMissionProgress>> getCustomerProgress(
      String customerId) async {
    final snapshot = await _progress
        .where('customerId', isEqualTo: customerId)
        .get();

    return snapshot.docs.map((doc) => _progressFromDoc(doc)).toList();
  }

  @override
  Future<CustomerMissionProgress> updateProgress(
      CustomerMissionProgress progress) async {
    final query = _progress
        .where('missionId', isEqualTo: progress.missionId)
        .where('customerId', isEqualTo: progress.customerId)
        .limit(1);

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      await _progress.add(_progressToDoc(progress));
    } else {
      await snapshot.docs.first.reference.update(_progressToDoc(progress));
    }

    return progress;
  }

  MissionModel _missionFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MissionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: _parseMissionType(data['type']),
      targetValue: data['targetValue'] ?? 0,
      reward: MissionReward(
        description: data['reward']?['description'] ?? '',
        discountValue: (data['reward']?['discountValue'] as num?)?.toDouble(),
        isFreeItem: data['reward']?['isFreeItem'],
        bonusPoints: data['reward']?['bonusPoints'],
      ),
      validUntil: data['validUntil'] != null
          ? (data['validUntil'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> _missionToDoc(MissionModel mission) {
    return {
      'title': mission.title,
      'description': mission.description,
      'type': mission.type.name,
      'targetValue': mission.targetValue,
      'reward': {
        'description': mission.reward.description,
        'discountValue': mission.reward.discountValue,
        'isFreeItem': mission.reward.isFreeItem,
        'bonusPoints': mission.reward.bonusPoints,
      },
      'validUntil': mission.validUntil,
      'isActive': mission.isActive,
    };
  }

  MissionType _parseMissionType(String? value) {
    return MissionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MissionType.orderCount,
    );
  }

  CustomerMissionProgress _progressFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerMissionProgress(
      missionId: data['missionId'] ?? '',
      customerId: data['customerId'] ?? '',
      currentValue: data['currentValue'] ?? 0,
      status: _parseMissionStatus(data['status']),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> _progressToDoc(CustomerMissionProgress progress) {
    return {
      'missionId': progress.missionId,
      'customerId': progress.customerId,
      'currentValue': progress.currentValue,
      'status': progress.status.name,
      'completedAt': progress.completedAt,
    };
  }

  MissionStatus _parseMissionStatus(String? value) {
    return MissionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MissionStatus.active,
    );
  }
}

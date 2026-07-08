import '../models/models.dart';
import '../repositories/mission_repository.dart';

class MockMissionRepository implements MissionRepository {
  final List<MissionModel> _missions = [
    MissionModel(
      id: 'm-001',
      title: 'Order 5x Dalam Sebulan',
      description: 'Lakukan 5 order dalam satu bulan kalender untuk mendapatkan diskon eksklusif.',
      type: MissionType.orderCount,
      targetValue: 5,
      reward: const MissionReward(
        description: 'Diskon 15% untuk order berikutnya',
        discountValue: 15,
      ),
      validUntil: DateTime(2025, 12, 31),
    ),
    MissionModel(
      id: 'm-002',
      title: 'Belanja Total Rp 300.000',
      description: 'Capai total belanja Rp 300.000 untuk mendapatkan bonus poin.',
      type: MissionType.orderAmount,
      targetValue: 300000,
      reward: const MissionReward(
        description: 'Bonus 100 poin loyalitas',
        bonusPoints: 100,
      ),
      validUntil: DateTime(2025, 12, 31),
    ),
    MissionModel(
      id: 'm-003',
      title: 'Ajak 3 Teman',
      description: 'Referensikan Devdara ke 3 teman dan dapatkan reward spesial.',
      type: MissionType.referral,
      targetValue: 3,
      reward: const MissionReward(
        description: 'Gratis 1x cuci pakaian reguler',
        isFreeItem: true,
      ),
      validUntil: DateTime(2025, 12, 31),
    ),
    MissionModel(
      id: 'm-004',
      title: 'Order Pertama',
      description: 'Selesaikan order pertamamu untuk mulai perjalanan bersama Devdara.',
      type: MissionType.firstOrder,
      targetValue: 1,
      reward: const MissionReward(
        description: 'Voucher diskon 20% untuk order berikutnya',
        discountValue: 20,
      ),
    ),
  ];

  final List<CustomerMissionProgress> _progresses = [
    const CustomerMissionProgress(
      missionId: 'm-001',
      customerId: 'cust-001',
      currentValue: 3,
      status: MissionStatus.active,
    ),
    const CustomerMissionProgress(
      missionId: 'm-002',
      customerId: 'cust-001',
      currentValue: 185000,
      status: MissionStatus.active,
    ),
    const CustomerMissionProgress(
      missionId: 'm-004',
      customerId: 'cust-001',
      currentValue: 1,
      status: MissionStatus.completed,
      completedAt: null,
    ),
  ];

  @override
  Future<List<MissionModel>> getAllMissions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_missions);
  }

  @override
  Future<List<MissionModel>> getActiveMissions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _missions.where((m) => m.isActive).toList();
  }

  @override
  Future<MissionModel> createMission(MissionModel mission) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _missions.add(mission);
    return mission;
  }

  @override
  Future<MissionModel> updateMission(MissionModel mission) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _missions.indexWhere((m) => m.id == mission.id);
    if (index == -1) throw Exception('Misi tidak ditemukan.');
    _missions[index] = mission;
    return mission;
  }

  @override
  Future<void> deleteMission(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _missions.removeWhere((m) => m.id == id);
  }

  @override
  Future<List<CustomerMissionProgress>> getCustomerProgress(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _progresses.where((p) => p.customerId == customerId).toList();
  }

  @override
  Future<CustomerMissionProgress> updateProgress(CustomerMissionProgress progress) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _progresses.indexWhere(
      (p) => p.missionId == progress.missionId && p.customerId == progress.customerId,
    );
    if (index == -1) {
      _progresses.add(progress);
    } else {
      _progresses[index] = progress;
    }
    return progress;
  }
}

import '../models/models.dart';

abstract class MissionRepository {
  /// Mengambil semua misi (untuk admin).
  Future<List<MissionModel>> getAllMissions();

  /// Mengambil misi yang aktif (untuk customer).
  Future<List<MissionModel>> getActiveMissions();

  /// Membuat misi baru.
  Future<MissionModel> createMission(MissionModel mission);

  /// Memperbarui data misi.
  Future<MissionModel> updateMission(MissionModel mission);

  /// Menghapus misi.
  Future<void> deleteMission(String id);

  /// Mengambil progress misi seorang customer.
  Future<List<CustomerMissionProgress>> getCustomerProgress(String customerId);

  /// Memperbarui progress misi customer (misal setelah order selesai).
  Future<CustomerMissionProgress> updateProgress(CustomerMissionProgress progress);
}

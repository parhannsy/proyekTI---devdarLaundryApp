import '../models/models.dart';

abstract class ReportRepository {
  /// Mengambil ringkasan laporan untuk rentang tanggal tertentu.
  Future<ReportSummary> getSummary({
    required DateTime from,
    required DateTime to,
  });

  /// Mengambil statistik harian dalam rentang tanggal.
  Future<List<DailyStat>> getDailyStats({
    required DateTime from,
    required DateTime to,
  });
}

/// Format tanggal menjadi label waktu relatif dalam Bahasa Indonesia.
///
/// Membandingkan `date` dengan hari ini (tanpa mempedulikan jam) dan
/// mengembalikan label seperti:
/// - ` (Hari Ini)`        — hari yang sama
/// - ` (Kemarin)`         — 1 hari yang lalu
/// - ` (3 hari lalu)`     — 2–7 hari yang lalu
/// - ` (2 minggu yang lalu)` — 8–30 hari yang lalu (pembulatan ke atas per minggu)
/// - ` (Bulan lalu)`      — 31+ hari yang lalu
///
/// Untuk tanggal di masa depan, mengembalikan string kosong.
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diffDays = today.difference(target).inDays;

  if (diffDays < 0) {
    // Tanggal masih di masa depan — tidak perlu label relatif
    return '';
  }

  if (diffDays == 0) {
    return ' (Hari Ini)';
  }

  if (diffDays == 1) {
    return ' (Kemarin)';
  }

  if (diffDays <= 7) {
    return ' ($diffDays hari lalu)';
  }

  if (diffDays >= 31) {
    return ' (Bulan lalu)';
  }

  // 8–30 hari: konversi ke minggu (pembulatan ke atas)
  final weeks = (diffDays / 7).ceil();
  return ' ($weeks minggu yang lalu)';
}

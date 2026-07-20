import 'package:intl/intl.dart';

/// Format angka menjadi format mata uang Rupiah.
///
/// Contoh:
/// - `formatRupiah(10000)` → `Rp 10.000`
/// - `formatRupiah(50000.5)` → `Rp 50.001`
/// - `formatRupiah(0)` → `Rp 0`
/// - `formatRupiah(null)` → `Rp 0`
String formatRupiah(dynamic value) {
  final num amount;
  if (value == null) {
    amount = 0;
  } else if (value is num) {
    amount = value;
  } else {
    amount = num.tryParse(value.toString()) ?? 0;
  }
  return NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}

/// Format angka menjadi format Rupiah kompak (ribuan).
///
/// Contoh:
/// - `formatRupiahCompact(1500)` → `Rp 1,5 rb`
/// - `formatRupiahCompact(2500000)` → `Rp 2,5 jt`
String formatRupiahCompact(dynamic value) {
  final num amount;
  if (value == null) {
    amount = 0;
  } else if (value is num) {
    amount = value;
  } else {
    amount = num.tryParse(value.toString()) ?? 0;
  }
  return NumberFormat.compactCurrency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 1,
  ).format(amount);
}

/// Format angka desimal menjadi format lokal Indonesia.
///
/// Contoh:
/// - `formatDecimal(1000.5)` → `1.000,5`
String formatDecimal(dynamic value) {
  final num amount;
  if (value == null) {
    amount = 0;
  } else if (value is num) {
    amount = value;
  } else {
    amount = num.tryParse(value.toString()) ?? 0;
  }
  return NumberFormat.decimalPattern('id').format(amount);
}

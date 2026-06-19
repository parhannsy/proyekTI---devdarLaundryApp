import 'package:flutter/material.dart';

class OrderHistory {
  final String orderId;
  final String serviceName;
  final double quantity;
  final String unit;
  final String date;
  final double totalPrice;
  final String status; // 'Proses', 'Selesai', 'Diambil', 'Ditolak'

  const OrderHistory({
    required this.orderId,
    required this.serviceName,
    required this.quantity,
    required this.unit,
    required this.date,
    required this.totalPrice,
    required this.status,
  });

  // Helper untuk mendapatkan warna background badge status
  Color getStatusBgColor() {
    switch (status.toLowerCase()) {
      case 'proses': return const Color(0xFFEBF3FF);
      case 'selesai': return const Color(0xFFE8F8F5);
      case 'diambil': return const Color(0xFFF0F4F8);
      case 'ditolak': return const Color(0xFFFFEAEA);
      default: return const Color(0xFFF0F4F8);
    }
  }

  // Helper untuk mendapatkan warna teks badge status
  Color getStatusTextColor() {
    switch (status.toLowerCase()) {
      case 'proses': return const Color(0xFF2F80ED);
      case 'selesai': return const Color(0xFF2ECC71);
      case 'diambil': return const Color(0xFF90A4AE);
      case 'ditolak': return const Color(0xFFE74C3C);
      default: return const Color(0xFF90A4AE);
    }
  }
}
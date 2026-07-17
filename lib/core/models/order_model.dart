/// Status pesanan — alur 5 tahap utama laundry.
///
/// 📝 REQUEST → ✅ ACCEPTED → 🔄 PROCESSING (pickedUp+processing)
///   → 🚛 DELIVERING → ✅ COMPLETED
///
/// Jalur batal: ❌ REJECTED (oleh admin) / ❌ CANCELLED (oleh customer)
import 'package:flutter/material.dart' show IconData, Icons;

enum OrderStatus {
  request,
  accepted,
  rejected,
  pickedUp,
  processing,
  delivering,
  completed,
  cancelled,
}

/// Kategori layanan cucian.
enum OrderCategory {
  regular,
  express,
  carpet,
  shoes,
  dryClean,
}

/// Satuan hitung barang yang akan dicuci.
enum UnitType {
  satuan, // pcs / buah
  kiloan, // kg
  meteran, // meter (karpet, kain lebar)
}

// ── Extension labels ──────────────────────────────────────────

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.request:
        return 'Permohonan';
      case OrderStatus.accepted:
        return 'Diterima';
      case OrderStatus.rejected:
        return 'Ditolak';
      case OrderStatus.pickedUp:
        return 'Diangkut';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.delivering:
        return 'Sedang Diantar';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  IconData get iconData {
    switch (this) {
      case OrderStatus.request:
        return Icons.edit_note_rounded;
      case OrderStatus.accepted:
        return Icons.check_circle_outline;
      case OrderStatus.rejected:
        return Icons.cancel_outlined;
      case OrderStatus.pickedUp:
        return Icons.local_shipping_outlined;
      case OrderStatus.processing:
        return Icons.local_laundry_service_outlined;
      case OrderStatus.delivering:
        return Icons.directions_car_outlined;
      case OrderStatus.completed:
        return Icons.task_alt_rounded;
      case OrderStatus.cancelled:
        return Icons.block_outlined;
    }
  }

  /// Progress value 0.0 – 1.0 untuk progress bar.
  double get progressValue {
    switch (this) {
      case OrderStatus.request:
        return 0.0;
      case OrderStatus.accepted:
        return 0.1;
      case OrderStatus.rejected:
        return 0.0;
      case OrderStatus.pickedUp:
        return 0.25;
      case OrderStatus.processing:
        return 0.55;
      case OrderStatus.delivering:
        return 0.8;
      case OrderStatus.completed:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
    }
  }

  /// Apakah status ini termasuk "aktif / sedang berjalan"?
  bool get isActive =>
      this != OrderStatus.completed &&
      this != OrderStatus.cancelled &&
      this != OrderStatus.rejected;
}

extension OrderCategoryLabel on OrderCategory {
  String get label {
    switch (this) {
      case OrderCategory.regular:
        return 'Reguler';
      case OrderCategory.express:
        return 'Express';
      case OrderCategory.carpet:
        return 'Karpet';
      case OrderCategory.shoes:
        return 'Sepatu';
      case OrderCategory.dryClean:
        return 'Dry Clean';
    }
  }
}

extension UnitTypeLabel on UnitType {
  String get label {
    switch (this) {
      case UnitType.satuan:
        return 'Satuan (pcs)';
      case UnitType.kiloan:
        return 'Kiloan (kg)';
      case UnitType.meteran:
        return 'Meteran (m)';
    }
  }

  String get shortLabel {
    switch (this) {
      case UnitType.satuan:
        return 'pcs';
      case UnitType.kiloan:
        return 'kg';
      case UnitType.meteran:
        return 'm';
    }
  }
}

// ── OrderModel ────────────────────────────────────────────────

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerAddress;
  final OrderCategory category;
  final String itemName; // nama barang
  final UnitType unitType;
  final double quantity; // jumlah sesuai unitType (kg / pcs / m)
  final OrderStatus status;
  final double totalPrice;
  final double discount;
  final String? voucherCode;
  final String? notes;
  final DateTime pickupDate;
  final String? rejectionReason;
  final double? estimatedTotal; // diisi admin saat accept
  final DateTime createdAt;
  final DateTime? completedAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerAddress = '',
    required this.category,
    this.itemName = '',
    this.unitType = UnitType.kiloan,
    this.quantity = 0,
    required this.status,
    this.totalPrice = 0,
    this.discount = 0,
    this.voucherCode,
    this.notes,
    required this.pickupDate,
    this.rejectionReason,
    this.estimatedTotal,
    required this.createdAt,
    this.completedAt,
  });

  /// Harga final setelah diskon.
  double get finalPrice => totalPrice - discount;

  /// Label untuk ditampilkan di UI: "3.5 kg" atau "2 pcs"
  String get quantityLabel => '${quantity.toString()} ${unitType.shortLabel}';

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerAddress,
    OrderCategory? category,
    String? itemName,
    UnitType? unitType,
    double? quantity,
    OrderStatus? status,
    double? totalPrice,
    double? discount,
    String? voucherCode,
    String? notes,
    DateTime? pickupDate,
    String? rejectionReason,
    double? estimatedTotal,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      category: category ?? this.category,
      itemName: itemName ?? this.itemName,
      unitType: unitType ?? this.unitType,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      discount: discount ?? this.discount,
      voucherCode: voucherCode ?? this.voucherCode,
      notes: notes ?? this.notes,
      pickupDate: pickupDate ?? this.pickupDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      estimatedTotal: estimatedTotal ?? this.estimatedTotal,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

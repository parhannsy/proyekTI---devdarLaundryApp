enum OrderStatus {
  pending,
  received,
  washing,
  drying,
  ironing,
  ready,
  delivered,
  cancelled,
}

enum OrderCategory {
  regular,
  express,
  carpet,
  shoes,
  dryClean,
}

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Menunggu';
      case OrderStatus.received:
        return 'Diterima';
      case OrderStatus.washing:
        return 'Dicuci';
      case OrderStatus.drying:
        return 'Dikeringkan';
      case OrderStatus.ironing:
        return 'Disetrika';
      case OrderStatus.ready:
        return 'Siap';
      case OrderStatus.delivered:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  double get progressValue {
    switch (this) {
      case OrderStatus.pending:
        return 0.05;
      case OrderStatus.received:
        return 0.2;
      case OrderStatus.washing:
        return 0.4;
      case OrderStatus.drying:
        return 0.6;
      case OrderStatus.ironing:
        return 0.8;
      case OrderStatus.ready:
        return 0.95;
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
    }
  }
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

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final OrderCategory category;
  final double weight;
  final int quantity;
  final OrderStatus status;
  final double totalPrice;
  final String? voucherCode;
  final double discount;
  final String? notes;
  final DateTime createdAt;
  final DateTime? estimatedDoneAt;
  final DateTime? completedAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.category,
    required this.weight,
    required this.quantity,
    required this.status,
    required this.totalPrice,
    this.voucherCode,
    this.discount = 0.0,
    this.notes,
    required this.createdAt,
    this.estimatedDoneAt,
    this.completedAt,
  });

  double get finalPrice => totalPrice - discount;

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    OrderCategory? category,
    double? weight,
    int? quantity,
    OrderStatus? status,
    double? totalPrice,
    String? voucherCode,
    double? discount,
    String? notes,
    DateTime? createdAt,
    DateTime? estimatedDoneAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      category: category ?? this.category,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      voucherCode: voucherCode ?? this.voucherCode,
      discount: discount ?? this.discount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      estimatedDoneAt: estimatedDoneAt ?? this.estimatedDoneAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

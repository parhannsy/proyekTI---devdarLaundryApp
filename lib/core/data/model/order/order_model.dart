import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String priceInfo;
  final double basePrice;
  final String unit;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.priceInfo,
    required this.basePrice,
    required this.unit,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class DiscountVoucher {
  final String code;
  final String description;
  final String validUntil;
  final String typeLabel; // 'Manual' atau 'Dari Misi'
  final Color badgeColor;
  final double? percentage;
  final double? fixedAmount;

  const DiscountVoucher({
    required this.code,
    required this.description,
    required this.validUntil,
    required this.typeLabel,
    required this.badgeColor,
    this.percentage,
    this.fixedAmount,
  });
}
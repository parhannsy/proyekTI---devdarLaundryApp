import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text(
          'Order',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColor.iconSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Halaman Order',
              style: TextStyle(
                fontSize: 18,
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
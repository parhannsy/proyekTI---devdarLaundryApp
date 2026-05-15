import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: AppColor.iconSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Halaman Profil',
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
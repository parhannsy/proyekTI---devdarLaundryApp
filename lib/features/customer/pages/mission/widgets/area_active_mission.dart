import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:flutter/material.dart';

class ActiveMissionCard extends StatelessWidget {
  final String title, reward, deadline;
  final int currentProgress, totalProgress;

  const ActiveMissionCard({
    super.key,
    // Menyiapkan data dummy default jika parameter tidak dikirim
    this.title = 'Misi Rahasia',
    this.reward = 'Hadiah Menarik',
    this.deadline = 'Segera Berakhir',
    this.currentProgress = 0,
    this.totalProgress = 100,
  });

  @override
  Widget build(BuildContext context) {
    double progressPercent = totalProgress > 0 ? (currentProgress / totalProgress) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_outline_rounded, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoRow(Icons.card_giftcard_rounded, reward),
              _infoRow(Icons.access_time_rounded, deadline),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 8,
              backgroundColor: Colors.blue.shade50,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColor.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$currentProgress/$totalProgress',
            style: const TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}
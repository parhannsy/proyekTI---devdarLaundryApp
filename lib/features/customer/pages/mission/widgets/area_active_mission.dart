import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_card.dart';

class ActiveMissionCard extends StatelessWidget {
  final String title, reward, deadline;
  final int currentProgress, totalProgress;

  const ActiveMissionCard({
    super.key,
    this.title = 'Misi Rahasia',
    this.reward = 'Hadiah Menarik',
    this.deadline = 'Segera Berakhir',
    this.currentProgress = 0,
    this.totalProgress = 100,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = totalProgress > 0 ? (currentProgress / totalProgress) : 0.0;
    return MinimalCard(
      radius: 14, withBorder: true,
      width: 280, padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_outline_rounded, color: AppColor.warning, size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColor.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: progressPercent, minHeight: 5,
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColor.primary)),
          ),
          const SizedBox(height: 6),
          Text('$currentProgress/$totalProgress', style: const TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColor.textMuted),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: AppColor.textSecondary, fontSize: 12)),
    ]);
  }
}
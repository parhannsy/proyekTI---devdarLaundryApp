import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';
import 'package:flutter/material.dart';

class CompletedMissionCard extends StatelessWidget {
  final String title, description;

  const CompletedMissionCard({
    super.key, 
    this.title = 'Misi Berhasil Diselesaikan', 
    this.description = 'Reward telah diklaim'
  });

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      radius: 20,
      elevation: 4,
      surfaceColor: Colors.white,
      borderColor: Colors.blue.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(color: Colors.green, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
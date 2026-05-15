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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade50),
      ),
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
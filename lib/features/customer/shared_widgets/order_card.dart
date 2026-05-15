// import 'package:devdar_laundry_pos_app/core/theme/app_colors.dart';
// import 'package:flutter/material.dart';

// class OrderCard extends StatelessWidget {
//   final String id;
//   final String category;
//   final String weight;
//   final String status;
//   final double progress;

//   const OrderCard({
//     super.key,
//     required this.id,
//     required this.category,
//     required this.weight,
//     required this.status,
//     required this.progress,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.black12.withOpacity(0.05)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(status, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text("$category · $weight", style: const TextStyle(color: AppColors.textGrey)),
//           const SizedBox(height: 12),
//           LinearProgressIndicator(
//             value: progress,
//             backgroundColor: AppColors.progressBarBase,
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(10),
//             minHeight: 8,
//           ),
//         ],
//       ),
//     );
//   }
// }
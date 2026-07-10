import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';
import 'package:flutter/material.dart';

class BuildQuickActions extends StatelessWidget {
  const BuildQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'icon': Icons.add_circle_outline,
        'label': 'Order Baru',
        'color': AppColor.primary
      },
      {
        'icon': Icons.history,
        'label': 'Riwayat',
        'color': AppColor.primary
      },
      {
        'icon': Icons.confirmation_number_outlined,
        'label': 'Diskon Saya',
        'color': AppColor.success
      },
      {
        'icon': Icons.people_outline,
        'label': 'Afiliasi',
        'color': AppColor.primary
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          final color = action['color'] as Color;

          return InkWell(
            onTap: () {
              debugPrint('Menu ${action['label']} diklik');
            },
            borderRadius: BorderRadius.circular(16),
            child: ClayContainer(
              radius: 16,
              elevation: 4,
              surfaceColor: AppColor.surface,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
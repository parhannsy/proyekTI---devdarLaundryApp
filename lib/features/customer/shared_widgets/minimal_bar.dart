import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';

/// Top bar minimalis yang konsisten di semua halaman customer.
///
/// — Background putih bersih tanpa efek claymorphism
/// — Title rata kiri dengan font bold
/// — Opsional leading (back button) dan actions (notifikasi, dll)
/// — Bottom border tipis untuk pemisah visual
class MinimalBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showNotification;
  final int notificationCount;
  final Color backgroundColor;
  final Color titleColor;
  final double elevation;

  const MinimalBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showNotification = false,
    this.notificationCount = 0,
    this.backgroundColor = Colors.white,
    this.titleColor = AppColor.textPrimary,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.12),
            width: elevation > 0 ? 0 : 0.5,
          ),
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: elevation * 0.04),
                  blurRadius: 8 * elevation,
                  offset: Offset(0, 2 * elevation),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          // Leading widget (back button or menu)
          if (leading != null)
            leading!
          else
            const SizedBox(width: 8),

          const SizedBox(width: 4),

          // Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary,
              ),
            ),
          ),

          // Actions
          if (actions != null) ...actions!,

          // Notification bell
          if (showNotification)
            _NotificationIcon(count: notificationCount),

          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final int count;

  const _NotificationIcon({this.count = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined,
                color: AppColor.iconSecondary, size: 24),
            splashRadius: 20,
          ),
          if (count > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColor.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

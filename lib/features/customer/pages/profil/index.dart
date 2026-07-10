import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/mini_stat_card.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/claymorphism/clay_container.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: CustomScrollView(
        slivers: [
          // ── Header SliverAppBar ───────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColor.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColor.gradientStart, AppColor.gradientEnd],
                  ),
                ),
                child: const SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 16),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Ahmad Farhan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'customer@devdara.com',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                const AnimatedFadeSlider(
                  index: 1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _StatsRow(),
                  ),
                ),

                const SizedBox(height: 24),

                const AnimatedFadeSlider(
                  index: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Akun',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                AnimatedFadeSlider(
                  index: 3,
                  child: _ProfileMenuItem(
                    icon: Icons.person_outline,
                    label: 'Edit Profil',
                    onTap: () {},
                  ),
                ),
                AnimatedFadeSlider(
                  index: 4,
                  child: _ProfileMenuItem(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Voucher Saya',
                    onTap: () {},
                  ),
                ),
                AnimatedFadeSlider(
                  index: 5,
                  child: _ProfileMenuItem(
                    icon: Icons.history,
                    label: 'Riwayat Order',
                    onTap: () {},
                  ),
                ),
                AnimatedFadeSlider(
                  index: 6,
                  child: _ProfileMenuItem(
                    icon: Icons.people_outline,
                    label: 'Program Afiliasi',
                    onTap: () {},
                  ),
                ),

                const SizedBox(height: 16),

                const AnimatedFadeSlider(
                  index: 7,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Lainnya',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                AnimatedFadeSlider(
                  index: 8,
                  child: _ProfileMenuItem(
                    icon: Icons.notifications_none,
                    label: 'Notifikasi',
                    onTap: () {},
                  ),
                ),
                AnimatedFadeSlider(
                  index: 9,
                  child: _ProfileMenuItem(
                    icon: Icons.help_outline,
                    label: 'Bantuan',
                    onTap: () {},
                  ),
                ),
                AnimatedFadeSlider(
                  index: 10,
                  child: _ProfileMenuItem(
                    icon: Icons.logout,
                    label: 'Keluar',
                    color: AppColor.error,
                    onTap: () {},
                  ),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MiniStatCard(
          label: 'Poin',
          value: '320',
          icon: Icons.star_rounded,
          color: AppColor.warning,
          showIconBackground: true,
        ),
        const SizedBox(width: 12),
        MiniStatCard(
          label: 'Total Hemat',
          value: 'Rp 125K',
          icon: Icons.savings_outlined,
          color: AppColor.success,
          showIconBackground: true,
        ),
        const SizedBox(width: 12),
        MiniStatCard(
          label: 'Order',
          value: '14x',
          icon: Icons.inventory_2_outlined,
          color: AppColor.primary,
          showIconBackground: true,
        ),
      ],
    );
  }
}

// ─── Profile Menu Item ────────────────────────────────────────────────────────

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColor.textPrimary;
    return InkWell(
      onTap: onTap,
      child: ClayContainer(
        radius: 14,
        elevation: 3,
        surfaceColor: AppColor.surface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: itemColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColor.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

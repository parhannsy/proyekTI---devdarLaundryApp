import 'package:devdar_laundry_pos_app/core/theme/formatter/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────
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

                // Stats row
                const AnimatedFadeSlider(
                  index: 1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _StatsRow(),
                  ),
                ),

                const SizedBox(height: 24),

                // Menu section label — Akun
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

                // Menu section label — Lainnya
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

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Poin',
          value: '320',
          icon: Icons.star_rounded,
          color: AppColor.warning,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Total Hemat',
          value: 'Rp 125K',
          icon: Icons.savings_outlined,
          color: AppColor.success,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Order',
          value: '14x',
          icon: Icons.inventory_2_outlined,
          color: AppColor.primary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(14),
        ),
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

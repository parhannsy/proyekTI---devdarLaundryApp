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
    return CustomScrollView(
      primary: true,
      slivers: [
        // --- BATAS AMAN ATAS (TOPBAR ADAPTER) ---
        // Menangani overlap dengan FloatingTopbar melayang agar konsisten dengan MissionPage
        Builder(
          builder: (context) => SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
        ),

        // --- KONTEN HALAMAN PROFIL ---
        SliverList(
          delegate: SliverChildListDelegate([
            // Elemen 1: Header Profil (Avatar, Nama, No. Telp)
            const AnimatedFadeSlider(
              index: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _ProfileHeaderSection(),
              ),
            ),
            const SizedBox(height: 24),
            // Elemen 2: Group Menu Utama
            AnimatedFadeSlider(
              index: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profil',
                        isFirst: true,
                        onTap: () {
                          // TODO: Navigasi ke halaman Edit Profil
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.location_on_outlined,
                        title: 'Alamat Saya',
                        onTap: () {
                          // TODO: Navigasi ke halaman Alamat
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.credit_card_rounded,
                        title: 'Metode Pembayaran',
                        onTap: () {
                          // TODO: Navigasi ke halaman Metode Pembayaran
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Bantuan',
                        onTap: () {
                          // TODO: Navigasi ke halaman Bantuan
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.shield_outlined,
                        title: 'Kebijakan Privasi',
                        onTap: () {
                          // TODO: Navigasi ke halaman Kebijakan Privasi
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.info_outline_rounded,
                        title: 'Tentang Aplikasi',
                        isLast: true,
                        onTap: () {
                          // TODO: Navigasi ke halaman Tentang Aplikasi
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Elemen 3: Tombol Keluar / Logout
            AnimatedFadeSlider(
              index: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () {
                    // TODO: Implementasi logika Logout
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFE57373),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Keluar',
                          style: TextStyle(
                            color: Color(0xFFE57373),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- BATAS AMAN BAWAH (BOTTOMBAR PADDING) ---
            // Menggunakan 150 sesuai standard MissionPage Anda agar tidak tertutup Floating Bottom Bar
            const SizedBox(height: 150),
          ]),
        ),
      ],
    );
  }

  // Helper Widget untuk membangun item menu
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(20) : Radius.zero,
            bottom: isLast ? const Radius.circular(20) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2196F3), size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.only(left: 60),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: Color(0xFFE0E0E0),
            ),
          ),
      ],
    );
  }
}

// Sub-widget internal khusus untuk bagian Header Profil agar kode utama tetap bersih
class _ProfileHeaderSection extends StatelessWidget {
  const _ProfileHeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
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
        const SizedBox(height: 16),
        const Text(
          'Ahmad Farhan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '+62 812-3456-7890',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF2C3E50).withOpacity(0.65),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

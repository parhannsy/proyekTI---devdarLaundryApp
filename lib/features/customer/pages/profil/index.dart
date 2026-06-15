import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/animated_fade_slider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'AF',
                  style: TextStyle(
                    color: Color(0xFF2196F3),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF2196F3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 16,
                ),
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
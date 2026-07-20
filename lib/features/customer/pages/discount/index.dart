import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/providers/voucher_provider.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/currency_formatter.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_bar.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'widgets/discount_card.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<VoucherModel> _vouchers = [];
  Set<String> _claimedVoucherIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVouchers());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    setState(() => _isLoading = true);
    try {
      final vp = context.read<VoucherProvider>();
      final auth = context.read<AuthProvider>();
      final userId = auth.currentUser?.id;

      // Load vouchers
      await vp.loadPublicVouchers();

      // Load claimed IDs (jika user sudah login)
      List<String> claimedIds = [];
      if (userId != null) {
        claimedIds = await vp.getClaimedVoucherIds(userId);
      }

      if (!mounted) return;
      setState(() {
        _vouchers = context.read<VoucherProvider>().activeVouchers;
        _claimedVoucherIds = claimedIds.toSet();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _claimVoucher(VoucherModel voucher) async {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id;
    if (userId == null) return;

    // Cek batas klaim (siapa cepat dia dapat)
    if (voucher.isClaimFull) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Maaf, kuota klaim voucher ini sudah penuh'),
            backgroundColor: AppColor.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      }
      return;
    }

    final vp = context.read<VoucherProvider>();
    // Simpan claim record dulu baru increment claimCount
    final success = await vp.claimVoucher(voucher.id, userId);
    if (!success) return;

    await vp.incrementClaimCount(voucher.id);

    if (mounted) {
      setState(() {
        // Update claimCount di data lokal agar isClaimFull langsung berefek
        _claimedVoucherIds.add(voucher.id);
        final idx = _vouchers.indexWhere((v) => v.id == voucher.id);
        if (idx != -1) {
          _vouchers[idx] = _vouchers[idx].copyWith(
            claimCount: _vouchers[idx].claimCount + 1,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Voucher "${voucher.code}" berhasil diklaim!'),
          backgroundColor: AppColor.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter: tersedia = belum diklaim + belum penuh claim limit-nya
    final claimed = _vouchers.where((v) => _claimedVoucherIds.contains(v.id)).toList();
    final available = _vouchers.where((v) =>
      !_claimedVoucherIds.contains(v.id) &&
      (v.claimLimit == null || v.claimCount < v.claimLimit!)
    ).toList();

    return Scaffold(
      backgroundColor: AppColor.background,
      body: Column(
        children: [
          const MinimalBar(title: 'Promo & Diskon'),

          // ── Stats summary ──
          AnimatedFadeSlider(
            index: 1,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColor.primary, Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_offer_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Promo Tersedia',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${available.length} diskon aktif untukmu',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${claimed.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'dimiliki',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Tab bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColor.primary,
                unselectedLabelColor: AppColor.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'Tersedia (${available.length})'),
                  Tab(text: 'Dimiliki (${claimed.length})'),
                ],
              ),
            ),
          ),

          // ── Content ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabContent(
                        vouchers: available,
                        emptyIcon: Icons.local_offer_outlined,
                        emptyMsg: 'Belum ada diskon tersedia',
                        emptySub: 'Cek kembali nanti untuk promo terbaru',
                        isClaimedList: false,
                      ),
                      _buildTabContent(
                        vouchers: claimed,
                        emptyIcon: Icons.card_giftcard_outlined,
                        emptyMsg: 'Belum ada diskon diklaim',
                        emptySub: 'Klaim diskon dari tab Tersedia',
                        isClaimedList: true,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent({
    required List<VoucherModel> vouchers,
    required IconData emptyIcon,
    required String emptyMsg,
    required String emptySub,
    required bool isClaimedList,
  }) {
    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 56, color: AppColor.textMuted),
            const SizedBox(height: 16),
            Text(
              emptyMsg,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColor.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              emptySub,
              style: const TextStyle(
                fontSize: 13,
                color: AppColor.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVouchers,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: vouchers.length,
        itemBuilder: (_, i) {
          final voucher = vouchers[i];
          return AnimatedFadeSlider(
            key: ValueKey(voucher.id),
            index: i + 1,
            child: DiscountCard(
              voucher: voucher,
              isClaimed: isClaimedList,
              onTap: () => _showVoucherDetail(voucher),
              onClaim: isClaimedList ? null : () => _claimVoucher(voucher),
            ),
          );
        },
      ),
    );
  }

  void _showVoucherDetail(VoucherModel voucher) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _VoucherDetailSheet(voucher: voucher),
    );
  }
}

// ─── Voucher Detail Bottom Sheet ─────────────────────────────────

class _VoucherDetailSheet extends StatelessWidget {
  final VoucherModel voucher;
  const _VoucherDetailSheet({required this.voucher});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Center(
            child: Text(
              voucher.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),

          // Kode
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColor.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.code, size: 16, color: AppColor.primary),
                  const SizedBox(width: 8),
                  Text(
                    voucher.code,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      // Copy to clipboard (simplified for now)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Kode "${voucher.code}" disalin!'),
                          backgroundColor: AppColor.success,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.copy_rounded,
                          size: 14, color: AppColor.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Info rows
          _infoRow(Icons.percent, 'Tipe', voucher.type.label),
          _infoRow(Icons.monetization_on_outlined, 'Nilai',
              voucher.valueDisplay),
          if (voucher.minimumOrder != null)
            _infoRow(Icons.shopping_cart_outlined, 'Min. Belanja',
                '${formatRupiah(voucher.minimumOrder!)}'),
          _infoRow(Icons.people_outline, 'Kuota',
              '${voucher.usedQuota}/${voucher.totalQuota} digunakan'),
          _infoRow(Icons.calendar_today_outlined, 'Berlaku s/d',
              '${voucher.validUntil.day}/${voucher.validUntil.month}/${voucher.validUntil.year}'),

          if (voucher.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              voucher.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColor.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColor.iconSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColor.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

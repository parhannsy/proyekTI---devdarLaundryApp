import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:devdar_laundry_pos_app/core/models/user_model.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/mini_stat_card.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/providers/auth_provider.dart';
import 'package:devdar_laundry_pos_app/core/providers/customer_provider.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_page_header.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_empty_state.dart';

class AdminCustomerPage extends StatefulWidget {
  const AdminCustomerPage({super.key});

  @override
  State<AdminCustomerPage> createState() => _AdminCustomerPageState();
}

class _AdminCustomerPageState extends State<AdminCustomerPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Muat data pelanggan dari Firestore saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadAllCustomers();
    });
  }

  List<UserModel> _filtered(CustomerProvider provider) {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return provider.customers;
    return provider.customers
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.email.toLowerCase().contains(q) ||
              c.phone.contains(q),
        )
        .toList();
  }

  String _tierFromPoints(int points) {
    if (points >= 200) return 'Gold';
    if (points >= 100) return 'Silver';
    return 'Bronze';
  }

  Color _tierColor(String tier) {
    switch (tier) {
      case 'Gold':
        return const Color(0xFFFFD700);
      case 'Silver':
        return Colors.grey;
      default:
        return const Color(0xFFCD7F32);
    }
  }

  void _showAddAccountDialog() {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    final authProvider = context.read<AuthProvider>();
    final customerProvider = context.read<CustomerProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_add_alt_1,
                  color: AppColor.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tambah Akun',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Buatkan akun baru untuk pelanggan.\nEmail dan password akan diberikan ke pelanggan.',
                  style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'contoh@email.com',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Minimal 6 karakter',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isLoading = true);
                      try {
                        await authProvider.register(
                          email: emailCtrl.text.trim(),
                          password: passCtrl.text,
                        );
                        // Refresh daftar customer setelah tambah akun
                        await customerProvider.loadAllCustomers();
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Akun ${emailCtrl.text.trim()} berhasil dibuat!',
                              ),
                              backgroundColor: AppColor.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Gagal: ${e.toString().replaceFirst("Exception: ", "")}',
                            ),
                            backgroundColor: AppColor.error,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Buat Akun'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAccountDialog,
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1, size: 20),
        label: const Text('Tambah Akun'),
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          // Error state
          if (provider.errorMessage != null && provider.customers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColor.error),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal memuat data pelanggan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => provider.loadAllCustomers(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Loading state
          if (provider.isLoading && provider.customers.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final customers = _filtered(provider);

          return Column(
            children: [
              AnimatedFadeSlider(
                index: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: AdminPageHeader(
                    title: 'Pelanggan',
                    subtitle: '${provider.customers.length} pelanggan terdaftar',
                  ),
                ),
              ),
              AnimatedFadeSlider(
                index: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      MiniStatCard(
                        label: 'Total',
                        value: '${provider.customers.length}',
                        icon: Icons.people_outline,
                        color: AppColor.primary,
                      ),
                      const SizedBox(width: 10),
                      MiniStatCard(
                        label: 'Gold',
                        value:
                            '${provider.customers.where((c) => _tierFromPoints(c.loyaltyPoints) == "Gold").length}',
                        icon: Icons.star_rounded,
                        color: const Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 10),
                      MiniStatCard(
                        label: 'Silver',
                        value:
                            '${provider.customers.where((c) => _tierFromPoints(c.loyaltyPoints) == "Silver").length}',
                        icon: Icons.star_half_rounded,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      MiniStatCard(
                        label: 'Bronze',
                        value:
                            '${provider.customers.where((c) => _tierFromPoints(c.loyaltyPoints) == "Bronze").length}',
                        icon: Icons.star_border_rounded,
                        color: const Color(0xFFCD7F32),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedFadeSlider(
                index: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Cari nama, email, atau nomor HP...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColor.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColor.iconSecondary,
                      ),
                      filled: true,
                      fillColor: AppColor.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: customers.isEmpty
                    ? AdminEmptyState(
                        icon: Icons.people_outline,
                        title: _searchQuery.isEmpty
                            ? 'Belum ada pelanggan'
                            : 'Pelanggan tidak ditemukan',
                        subtitle: _searchQuery.isEmpty
                            ? 'Tambah pelanggan baru untuk memulai'
                            : 'Coba kata kunci yang berbeda',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: customers.length,
                        itemBuilder: (_, i) => AnimatedFadeSlider(
                          index: i + 1,
                          child: _CustomerCard(
                            customer: customers[i],
                            tier: _tierFromPoints(customers[i].loyaltyPoints),
                            tierColor: _tierColor(_tierFromPoints(customers[i].loyaltyPoints)),
                            onDetail: () =>
                                _showCustomerDetail(context, customers[i]),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCustomerDetail(BuildContext context, UserModel customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CustomerDetailSheet(customer: customer),
    );
  }
}

// ─── Customer Card ────────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  final UserModel customer;
  final String tier;
  final Color tierColor;
  final VoidCallback onDetail;

  const _CustomerCard({
    required this.customer,
    required this.tier,
    required this.tierColor,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDetail,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColor.primary.withValues(alpha: 0.1),
              child: Text(
                customer.name.isNotEmpty
                    ? customer.name.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          customer.name.isNotEmpty ? customer.name : '(Tanpa Nama)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColor.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tierColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tier,
                          style: TextStyle(
                            fontSize: 10,
                            color: tierColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    customer.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColor.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    customer.phone.isNotEmpty ? customer.phone : '-',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColor.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColor.warning,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${customer.loyaltyPoints}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColor.warning,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'poin',
                  style: TextStyle(fontSize: 10, color: AppColor.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Customer Detail Sheet ────────────────────────────────────────────────────

class _CustomerDetailSheet extends StatelessWidget {
  final UserModel customer;
  const _CustomerDetailSheet({required this.customer});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'id');
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColor.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColor.primary.withValues(alpha: 0.1),
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name.substring(0, 1)
                      : '?',
                  style: const TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name.isNotEmpty ? customer.name : '(Tanpa Nama)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Bergabung ${dateFormat.format(customer.createdAt)}',
                    style: const TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          _row(Icons.email_outlined, 'Email', customer.email),
          _row(Icons.phone_outlined, 'Telepon', customer.phone),
          if (customer.nickname != null && customer.nickname!.isNotEmpty)
            _row(Icons.face_outlined, 'Panggilan', customer.nickname!),
          _row(Icons.star_rounded, 'Poin', '${customer.loyaltyPoints} poin'),
          _row(
            Icons.savings_outlined,
            'Total Hemat',
            currencyFormat.format(customer.totalSavings),
          ),
          if (customer.address != null && customer.address!.isNotEmpty)
            _row(Icons.home_outlined, 'Alamat', customer.address!),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Tutup'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColor.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColor.textSecondary),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

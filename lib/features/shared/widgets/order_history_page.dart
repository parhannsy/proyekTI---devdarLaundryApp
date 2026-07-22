import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:devdar_laundry_pos_app/core/models/models.dart';
import 'package:devdar_laundry_pos_app/core/providers/order_provider.dart';
import 'package:devdar_laundry_pos_app/core/providers/customer_provider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/currency_formatter.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/order_detail_sheet.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_empty_state.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_page_header.dart';
import 'package:devdar_laundry_pos_app/features/customer/shared_widgets/minimal_bar.dart';
import 'package:devdar_laundry_pos_app/core/router/app_router.dart';

/// Preset rentang tanggal.
enum _DatePreset { today, last7Days, thisMonth, all }

/// Halaman riwayat order yang sudah selesai (completed).
///
/// Untuk Customer: MinimalBar + back button (via [isCustomer]).
/// Untuk Admin: AdminPageHeader + back button + filter customer + filter tanggal.
class OrderHistoryPage extends StatefulWidget {
  final String title;
  final bool isCustomer;

  const OrderHistoryPage({
    super.key,
    this.title = 'Riwayat Order',
    this.isCustomer = false,
  });

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  // ── Filter state (Admin) ──────────────────────────────────
  String? _selectedCustomerId;
  _DatePreset _datePreset = _DatePreset.all;

  @override
  void initState() {
    super.initState();
    if (!widget.isCustomer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<OrderProvider>().listenAllOrders();
        context.read<CustomerProvider>().listenCustomers();
      });
    }
  }

  @override
  void dispose() {
    if (!widget.isCustomer) {
      context.read<OrderProvider>().stopListening();
    }
    super.dispose();
  }

  // ── Filter logic ──────────────────────────────────────────

  List<OrderModel> _applyFilters(List<OrderModel> orders) {
    var filtered = orders.where((o) => o.status == OrderStatus.completed);

    if (_selectedCustomerId != null) {
      filtered = filtered.where((o) => o.customerId == _selectedCustomerId);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_datePreset) {
      case _DatePreset.today:
        filtered = filtered.where((o) =>
            !o.createdAt.isBefore(today) &&
            o.createdAt.isBefore(today.add(const Duration(days: 1))));
        break;
      case _DatePreset.last7Days:
        final weekAgo = today.subtract(const Duration(days: 7));
        filtered = filtered.where(
            (o) => !o.createdAt.isBefore(weekAgo) && !o.createdAt.isAfter(now));
        break;
      case _DatePreset.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        filtered = filtered.where(
            (o) => !o.createdAt.isBefore(monthStart) && !o.createdAt.isAfter(now));
        break;
      case _DatePreset.all:
        break;
    }

    return filtered.toList();
  }

  void _onFilterPresetSelected(_DatePreset preset) {
    setState(() => _datePreset = preset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isCustomer ? AppColor.background : Colors.transparent,
      body: Consumer<OrderProvider>(
        builder: (context, orderProv, _) {
          final completedOrders = _applyFilters(orderProv.orders);

          return Column(
            children: [
              // ── Header ──────────────────────────────
              if (widget.isCustomer)
                MinimalBar(
                  title: widget.title,
                  leading: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColor.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              else
                _buildAdminHeader(context, completedOrders.length),

              // ── Filter bar (Admin) ──────────────────
              if (!widget.isCustomer) _buildAdminFilters(context),

              // ── Content ──────────────────────────────
              Expanded(
                child: completedOrders.isEmpty
                    ? Center(
                        child: AdminEmptyState(
                          icon: Icons.history_toggle_off_outlined,
                          title: 'Tidak ada riwayat',
                          subtitle: 'Coba ubah filter atau periode tanggal',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        itemCount: completedOrders.length,
                        itemBuilder: (_, i) => AnimatedFadeSlider(
                          key: ValueKey(completedOrders[i].id),
                          index: i + 1,
                          child: _HistoryCard(order: completedOrders[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Admin header ──────────────────────────────────────────

  Widget _buildAdminHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go(AppRoutes.adminOrders),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColor.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: AnimatedFadeSlider(
              index: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AdminPageHeader(
                  title: widget.title,
                  subtitle: '$count pesanan selesai',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Admin filters ─────────────────────────────────────────

  Widget _buildAdminFilters(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, custProv, _) {
        final customers = custProv.customers;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row: Customer dropdown + Filter button ──
              Row(
                children: [
                  // Customer dropdown
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: _selectedCustomerId,
                      decoration: InputDecoration(
                        hintText: 'Semua Pelanggan',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColor.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColor.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColor.textPrimary,
                      ),
                      dropdownColor: AppColor.surface,
                      icon: const Icon(Icons.arrow_drop_down_rounded,
                          color: AppColor.iconSecondary),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Semua Pelanggan'),
                        ),
                        ...customers.map((c) => DropdownMenuItem<String?>(
                              value: c.id,
                              child: Text(c.name.isNotEmpty ? c.name : c.email),
                            )),
                      ],
                      onChanged: (v) => setState(() => _selectedCustomerId = v),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // ── Tombol Filter Waktu ──────────────
                  _buildFilterButton(),
                ],
              ),

              // ── Active filter indicator ───────────
              if (_datePreset != _DatePreset.all)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _buildActiveFilterChip(),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Tombol dropdown untuk memilih preset waktu.
  Widget _buildFilterButton() {
    final isActive = _datePreset != _DatePreset.all;
    final label = _filterButtonLabel();

    return PopupMenuButton<_DatePreset>(
      onSelected: _onFilterPresetSelected,
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (_) => [
        _popupItem('Hari Ini', _DatePreset.today, Icons.today_rounded),
        _popupItem('7 Hari', _DatePreset.last7Days, Icons.date_range_rounded),
        _popupItem('Bulan Ini', _DatePreset.thisMonth, Icons.calendar_month_rounded),
        _popupItem('Semua Waktu', _DatePreset.all, Icons.unfold_more_rounded),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? AppColor.primary : AppColor.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColor.primary : AppColor.divider,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range_rounded,
              size: 18,
              color: isActive ? Colors.white : AppColor.iconSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.white : AppColor.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: isActive ? Colors.white70 : AppColor.iconSecondary,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<_DatePreset> _popupItem(
      String label, _DatePreset preset, IconData icon) {
    final isSelected = _datePreset == preset;
    return PopupMenuItem<_DatePreset>(
      value: preset,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? AppColor.primary : AppColor.iconSecondary,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColor.primary : AppColor.textPrimary,
            ),
          ),
          if (isSelected) const Spacer(),
          if (isSelected)
            const Icon(Icons.check_rounded,
                size: 16, color: AppColor.primary),
        ],
      ),
    );
  }

  String _filterButtonLabel() {
    switch (_datePreset) {
      case _DatePreset.today:
        return 'Hari Ini';
      case _DatePreset.last7Days:
        return '7 Hari';
      case _DatePreset.thisMonth:
        return 'Bulan Ini';
      case _DatePreset.all:
        return 'Filter Waktu';
    }
  }

  /// Chip yang menunjukkan filter aktif.
  Widget _buildActiveFilterChip() {
    String chipLabel;
    IconData chipIcon;

    switch (_datePreset) {
      case _DatePreset.today:
        chipLabel = 'Hari Ini';
        chipIcon = Icons.today_rounded;
      case _DatePreset.last7Days:
        chipLabel = '7 Hari Terakhir';
        chipIcon = Icons.date_range_rounded;
      case _DatePreset.thisMonth:
        chipLabel = 'Bulan Ini';
        chipIcon = Icons.calendar_month_rounded;
      case _DatePreset.all:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColor.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 14, color: AppColor.primary),
          const SizedBox(width: 6),
          Text(
            chipLabel,
            style: const TextStyle(
              fontSize: 12,
              color: AppColor.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── History Card ────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final OrderModel order;

  const _HistoryCard({required this.order});

  String _formatDate(DateTime dt) {
    return DateFormat('d MMM yyyy', 'id').format(dt);
  }

  String _durationLabel() {
    if (order.completedAt == null) return '';
    final diff = order.completedAt!.difference(order.createdAt);
    final days = diff.inDays;
    if (days == 0) {
      final hours = diff.inHours;
      if (hours == 0) {
        final minutes = diff.inMinutes;
        return 'Selesai dalam $minutes menit';
      }
      return 'Selesai dalam $hours jam';
    }
    return 'Selesai dalam $days hari';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => OrderDetailSheet.show(context, order),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.itemName.isNotEmpty ? order.itemName : order.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 14, color: AppColor.success),
                      const SizedBox(width: 4),
                      const Text(
                        'Selesai',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColor.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Info chips ─────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _infoChip(
                  Icons.inventory_2_outlined,
                  '${order.category.label} • ${order.quantityLabel}',
                ),
                _infoChip(
                  Icons.calendar_today_outlined,
                  'Dibuat: ${_formatDate(order.createdAt)}',
                ),
                _infoChip(
                  Icons.task_alt_rounded,
                  'Selesai: ${_formatDate(order.completedAt ?? order.createdAt)}',
                ),
                if (order.finalPrice > 0)
                  _infoChip(
                    Icons.payments_outlined,
                    formatRupiah(order.finalPrice),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Duration badge ──────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 14, color: AppColor.info.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Text(
                    _durationLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColor.info.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColor.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

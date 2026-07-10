import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/features/shared/widgets/animated_fade_slider.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_page_header.dart';
import 'package:devdar_laundry_pos_app/features/admin/shared_widgets/admin_empty_state.dart';

class AdminMissionPage extends StatefulWidget {
  const AdminMissionPage({super.key});

  @override
  State<AdminMissionPage> createState() => _AdminMissionPageState();
}

class _AdminMissionPageState extends State<AdminMissionPage> {
  final _missions = [
    _MissionData(
      id: 'm-001',
      title: 'Order 5x Dalam Sebulan',
      description: 'Lakukan 5 order dalam satu bulan kalender.',
      type: 'Jumlah Order',
      target: '5x',
      reward: 'Diskon 15%',
      participants: 34,
      completed: 12,
      isActive: true,
    ),
    _MissionData(
      id: 'm-002',
      title: 'Belanja Total Rp 300.000',
      description: 'Capai total belanja Rp 300.000.',
      type: 'Nilai Order',
      target: 'Rp 300.000',
      reward: 'Bonus 100 poin',
      participants: 28,
      completed: 8,
      isActive: true,
    ),
    _MissionData(
      id: 'm-003',
      title: 'Ajak 3 Teman',
      description: 'Referensikan Devdara ke 3 teman.',
      type: 'Referral',
      target: '3 orang',
      reward: 'Gratis 1x cuci',
      participants: 15,
      completed: 4,
      isActive: true,
    ),
    _MissionData(
      id: 'm-004',
      title: 'Order Pertama',
      description: 'Selesaikan order pertamamu.',
      type: 'Pencapaian',
      target: '1 order',
      reward: 'Voucher 20%',
      participants: 89,
      completed: 89,
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          AnimatedFadeSlider(
            index: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: AdminPageHeader(
                title: 'Kelola Misi',
                subtitle: '${_missions.length} misi terdaftar',
                actions: [
                  ElevatedButton.icon(
                    onPressed: () => _showMissionDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.warning,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text(
                      'Misi Baru',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Summary chips
          AnimatedFadeSlider(
            index: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _SummaryChip(
                    label: 'Total Misi',
                    value: '${_missions.length}',
                    color: AppColor.primary,
                  ),
                  const SizedBox(width: 10),
                  _SummaryChip(
                    label: 'Aktif',
                    value: '${_missions.where((m) => m.isActive).length}',
                    color: AppColor.success,
                  ),
                  const SizedBox(width: 10),
                  _SummaryChip(
                    label: 'Total Peserta',
                    value: '${_missions.fold(0, (s, m) => s + m.participants)}',
                    color: AppColor.info,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _missions.isEmpty
                ? const AdminEmptyState(
                    icon: Icons.track_changes_outlined,
                    title: 'Belum ada misi',
                    subtitle: 'Buat misi untuk mendorong pelanggan lebih aktif',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _missions.length,
                    itemBuilder: (_, i) => AnimatedFadeSlider(
                      index: i + 1,
                      child: _MissionCard(
                        mission: _missions[i],
                        onEdit: () =>
                            _showMissionDialog(context, mission: _missions[i]),
                        onToggle: () => setState(() {
                          _missions[i] = _MissionData(
                            id: _missions[i].id,
                            title: _missions[i].title,
                            description: _missions[i].description,
                            type: _missions[i].type,
                            target: _missions[i].target,
                            reward: _missions[i].reward,
                            participants: _missions[i].participants,
                            completed: _missions[i].completed,
                            isActive: !_missions[i].isActive,
                          );
                        }),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showMissionDialog(BuildContext context, {_MissionData? mission}) {
    showDialog(
      context: context,
      builder: (_) => _MissionDialog(mission: mission),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final _MissionData mission;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _MissionCard({
    required this.mission,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final completionRate = mission.participants > 0
        ? mission.completed / mission.participants
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mission.isActive
              ? AppColor.success.withValues(alpha: 0.3)
              : AppColor.divider,
        ),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: AppColor.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    Text(
                      'Target: ${mission.target} • ${mission.type}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: mission.isActive,
                onChanged: (_) => onToggle(),
                activeTrackColor: AppColor.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.card_giftcard_outlined,
                size: 14,
                color: AppColor.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Reward: ${mission.reward}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColor.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatPill(
                label: 'Peserta',
                value: '${mission.participants}',
                color: AppColor.info,
              ),
              const SizedBox(width: 8),
              _StatPill(
                label: 'Selesai',
                value: '${mission.completed}',
                color: AppColor.success,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tingkat penyelesaian: ${(completionRate * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completionRate,
                        backgroundColor: AppColor.progressBackground,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColor.success,
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColor.primary,
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                tooltip: 'Edit',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
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

class _MissionDialog extends StatelessWidget {
  final _MissionData? mission;
  const _MissionDialog({this.mission});

  @override
  Widget build(BuildContext context) {
    final isEdit = mission != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Edit Misi' : 'Buat Misi Baru',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _field('Judul Misi', Icons.title_outlined, initial: mission?.title),
            const SizedBox(height: 10),
            _field(
              'Deskripsi',
              Icons.description_outlined,
              initial: mission?.description,
            ),
            const SizedBox(height: 10),
            _field(
              'Tipe (Order/Referral/dll)',
              Icons.category_outlined,
              initial: mission?.type,
            ),
            const SizedBox(height: 10),
            _field('Target', Icons.flag_outlined, initial: mission?.target),
            const SizedBox(height: 10),
            _field(
              'Reward',
              Icons.card_giftcard_outlined,
              initial: mission?.reward,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEdit ? 'Misi diperbarui' : 'Misi dibuat',
                          ),
                          backgroundColor: AppColor.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.warning,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String hint, IconData icon, {String? initial}) {
    return TextField(
      controller: initial != null ? TextEditingController(text: initial) : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColor.iconSecondary),
        filled: true,
        fillColor: AppColor.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

class _MissionData {
  final String id, title, description, type, target, reward;
  final int participants, completed;
  final bool isActive;

  const _MissionData({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.reward,
    required this.participants,
    required this.completed,
    required this.isActive,
  });
}

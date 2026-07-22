import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/core/theme/formatter/app_colors.dart';

/// Data untuk antrian toast.
class _QueuedToast {
  final BuildContext context;
  final int count;
  _QueuedToast(this.context, this.count);
}

/// Service untuk menampilkan toast notifikasi order masuk.
///
/// Menggunakan antrian (queue) agar toast tidak saling menimpa.
/// Satu toast tampil → auto-hide → toast berikutnya dari antrian.
class OrderToastService {
  OrderToastService._();

  static final List<_QueuedToast> _queue = [];
  static bool _isShowing = false;

  /// Tampilkan toast: "[count] permohonan order masuk, segera ambil tindakan".
  static void showRequestToast(BuildContext context, int count) {
    // Hindari duplikasi: jika ada toast yang sama di antrian, skip
    final alreadyQueued = _queue.any((t) => t.count == count);
    if (alreadyQueued && _isShowing) return;

    _queue.add(_QueuedToast(context, count));
    _processQueue();
  }

  static void _processQueue() {
    if (_isShowing || _queue.isEmpty) return;
    _isShowing = true;

    final toast = _queue.removeAt(0);
    _showOverlay(toast.context, toast.count);
  }

  static void _showOverlay(BuildContext context, int count) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _OrderToast(
        count: count,
        onDismissed: () {
          entry.remove();
          _isShowing = false;
          _processQueue();
        },
      ),
    );

    overlay.insert(entry);
  }
}

/// Widget toast individual dengan animasi slide-in/slide-out.
class _OrderToast extends StatefulWidget {
  final int count;
  final VoidCallback onDismissed;

  const _OrderToast({
    required this.count,
    required this.onDismissed,
  });

  @override
  State<_OrderToast> createState() => _OrderToastState();
}

class _OrderToastState extends State<_OrderToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slideIn;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    ));

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Mulai animasi masuk
    _ctrl.forward();

    // Jadwalkan auto-dismiss
    Future.delayed(const Duration(seconds: 5), _dismiss);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    // Animasi keluar
    await _ctrl.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideIn,
        child: FadeTransition(
          opacity: _fadeIn,
          child: Material(
            elevation: 8,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(14),
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF283593)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ── Icon ──────────────────────
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ── Text ───────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.count == 1
                                ? '1 Permohonan Baru'
                                : '${widget.count} Permohonan Baru',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.count == 1
                                ? '1 permohonan order masuk, segera ambil tindakan'
                                : '$widget.count permohonan order masuk, segera ambil tindakan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Close button ─────────────
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: IconButton(
                        onPressed: _dismiss,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

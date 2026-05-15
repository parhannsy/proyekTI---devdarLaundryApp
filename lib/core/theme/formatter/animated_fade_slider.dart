import 'package:flutter/material.dart';

class AnimatedFadeSlider extends StatefulWidget {
  final Widget child;
  final int index;
  final Axis direction;
  final double offset;
  // Tambahkan parameter untuk memicu reverse secara manual dari luar jika perlu
  final bool isExiting; 

  const AnimatedFadeSlider({
    super.key,
    required this.child,
    required this.index,
    this.direction = Axis.vertical,
    this.offset = 30.0,
    this.isExiting = false,
  });

  @override
  State<AnimatedFadeSlider> createState() => _AnimatedFadeSliderState();
}

class _AnimatedFadeSliderState extends State<AnimatedFadeSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Durasi sedikit dipercepat agar snappy
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    final beginOffset = widget.direction == Axis.vertical
        ? Offset(0, widget.offset / 100)
        : Offset(widget.offset / 100, 0);

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Jalankan animasi masuk
    _playAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedFadeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika state isExiting berubah menjadi true, jalankan reverse
    if (widget.isExiting && !oldWidget.isExiting) {
      _controller.reverse();
    } else if (!widget.isExiting && oldWidget.isExiting) {
      _playAnimation();
    }
  }

  void _playAnimation() {
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
import 'package:flutter/material.dart';

/// ██████  ShimmerLoader — Skeleton loading claymorphism  ██████
///
/// Menampilkan animasi skeleton loading bergelombang (shimmer)
/// dengan bentuk dasar claymorphism.
///
/// Contoh penggunaan:
/// ```dart
/// // Circular shimmer (avatar)
/// ShimmerLoader.circular(radius: 40)
///
/// // Rectangular shimmer (card)
/// ShimmerLoader(
///   width: double.infinity,
///   height: 80,
/// )
///
/// // Custom child dengan shimmer
/// ShimmerLoader(
///   child: MyWidget(),  // child akan ditimpa efek shimmer
/// )
/// ```
class ShimmerLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry margin;
  final Widget? child;
  final bool isCircular;

  const ShimmerLoader({
    super.key,
    this.width,
    this.height,
    this.radius = 16,
    this.margin = const EdgeInsets.symmetric(vertical: 6),
    this.child,
    this.isCircular = false,
  });

  const ShimmerLoader.circular({
    super.key,
    required this.radius,
    this.margin = const EdgeInsets.all(4),
  })  : width = radius * 2,
        height = radius * 2,
        child = null,
        isCircular = true;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EDF5),
            borderRadius: widget.isCircular
                ? BorderRadius.circular(widget.radius)
                : BorderRadius.circular(widget.radius),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                offset: const Offset(-2, -2),
                blurRadius: 6,
              ),
              BoxShadow(
                color: const Color(0xFFD0D8E8).withValues(alpha: 0.5),
                offset: const Offset(3, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: widget.child ??
              Stack(
                children: [
                  // Shimmer sliding overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: widget.isCircular
                          ? BorderRadius.circular(widget.radius)
                          : BorderRadius.circular(widget.radius),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFFE8EDF5),
                            const Color(0xFFF0F4FF).withValues(alpha: 0.3),
                            const Color(0xFFE8EDF5),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          transform:
                              _SlideTransform(_animation.value),
                        ).createShader(bounds),
                        blendMode: BlendMode.srcATop,
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        );
      },
    );
  }
}

/// Transform untuk menggeser gradient shimmer
class _SlideTransform extends GradientTransform {
  final double value;
  const _SlideTransform(this.value);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * value, 0, 0);
  }
}

/// ====== Skeleton layout helpers ======

/// Menampilkan skeleton untuk satu baris kartu claymorphism
class ShimmerCard extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry margin;

  const ShimmerCard({
    super.key,
    this.height = 100,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      width: double.infinity,
      height: height,
      margin: margin,
    );
  }
}

/// Menampilkan skeleton untuk grid (misal quick menu)
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double itemWidth;
  final int crossAxisCount;

  const ShimmerGrid({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 80,
    this.itemWidth = 80,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (int row = 0;
              row < (itemCount / crossAxisCount).ceil();
              row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  for (int col = 0;
                      col < crossAxisCount && (row * crossAxisCount + col) < itemCount;
                      col++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: col > 0 ? 12 : 0,
                          right: col < crossAxisCount - 1 ? 12 : 0,
                        ),
                        child: ShimmerLoader(
                          width: double.infinity,
                          height: itemHeight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Menampilkan skeleton untuk baris horizontal (promo banner)
class ShimmerHorizontalList extends StatelessWidget {
  final int itemCount;
  final double itemWidth;
  final double itemHeight;

  const ShimmerHorizontalList({
    super.key,
    this.itemCount = 3,
    this.itemWidth = 200,
    this.itemHeight = 130,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight + 20,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        itemBuilder: (_, i) => Padding(
          padding: EdgeInsets.only(
            left: i == 0 ? 0 : 12,
            right: i == itemCount - 1 ? 0 : 0,
          ),
          child: ShimmerLoader(
            width: itemWidth,
            height: itemHeight,
          ),
        ),
      ),
    );
  }
}

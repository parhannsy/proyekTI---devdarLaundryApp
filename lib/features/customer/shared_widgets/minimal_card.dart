import 'package:flutter/material.dart';

/// Kartu minimalis — pengganti ClayContainer.
///
/// Ciri minimalis:
/// — Background putih bersih
/// — Border subtle (jika [withBorder]=true) sebagai pengganti shadow
/// — Shadow opsional, dibuat sangat ringan
/// — Radius 12px konsisten
class MinimalCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double radius;
  final bool withBorder;
  final bool withShadow;
  final VoidCallback? onTap;

  const MinimalCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.radius = 12,
    this.withBorder = true,
    this.withShadow = false,
    this.onTap,
  });

  /// Constructor cepat tanpa border (untuk layout yang lebih flat)
  const MinimalCard.flat({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.radius = 12,
    this.onTap,
  })  : borderColor = null,
        withBorder = false,
        withShadow = false;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: withBorder && borderColor != null
            ? Border.all(color: borderColor!)
            : withBorder
                ? Border.all(color: Colors.grey.withValues(alpha: 0.12))
                : null,
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child ?? const SizedBox.shrink(),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: card,
        ),
      );
    }

    return card;
  }
}

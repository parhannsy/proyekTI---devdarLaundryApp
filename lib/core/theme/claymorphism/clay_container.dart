import 'package:flutter/material.dart';
import '../formatter/app_colors.dart';

/// ██████  Claymorphism Container — Soft UI ala tanah liat  ██████
///
/// Efek double-shadow khas claymorphism:
///  - light shadow (top-left, putih) → menyiratkan sumber cahaya
///  - dark shadow  (bottom-right)    → menyiratkan kedalaman
///
/// [elevation] mengontrol seberapa "menonjol" elemen (4 = default clay).
/// [pressed] = true → shadow dibalik (efek "tertekan").
/// [surfaceColor] default = putih (AppColor.surface).
/// [borderColor] opsional untuk outline subtle.
class ClayContainer extends StatelessWidget {
  final Widget? child;
  final double elevation;
  final bool pressed;
  final Color surfaceColor;
  final Color? borderColor;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final Alignment alignment;
  final Clip clipBehavior;

  const ClayContainer({
    super.key,
    this.child,
    this.elevation = 4,
    this.pressed = false,
    this.surfaceColor = AppColor.surface,
    this.borderColor,
    this.radius = 16,
    this.padding,
    this.margin,
    this.gradient,
    this.width,
    this.height,
    this.constraints,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.none,
  });

  /// Constructor cepat untuk raised (timbul) — default
  const ClayContainer.raised({
    super.key,
    this.child,
    this.elevation = 4,
    this.surfaceColor = AppColor.surface,
    this.borderColor,
    this.radius = 16,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.none,
  })  : pressed = false,
        gradient = null;

  /// Constructor cepat untuk pressed / inset (tertekan)
  const ClayContainer.pressed({
    super.key,
    this.child,
    this.elevation = 4,
    this.surfaceColor = AppColor.surface,
    this.borderColor,
    this.radius = 16,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.none,
  })  : pressed = true,
        gradient = null;

  /// Intensitas shadow disesuaikan elevation (1-8)
  double get _shadowIntensity => (elevation / 8).clamp(0.1, 0.6);

  Color get _darkShadowColor =>
      AppColor.primary.withValues(alpha: _shadowIntensity * 0.25);

  Color get _lightShadowColor =>
      Colors.white.withValues(alpha: _shadowIntensity * 0.8);

  @override
  Widget build(BuildContext context) {
    final effectiveChild = child ?? const SizedBox.shrink();
    final effectivePadding = padding ?? (child != null ? const EdgeInsets.all(16) : EdgeInsets.zero);
    // Offset: raised = dark-BR, light-TL ; pressed = sebaliknya
    final double offset = elevation * 1.5;
    final double blur = elevation * 3.5;

    final List<BoxShadow> shadows;
    if (pressed) {
      // Efek inset : dark di TL, light di BR
      shadows = [
        BoxShadow(
          color: _darkShadowColor,
          offset: Offset(-offset * 0.6, -offset * 0.6),
          blurRadius: blur * 0.7,
        ),
        BoxShadow(
          color: _lightShadowColor,
          offset: Offset(offset * 0.6, offset * 0.6),
          blurRadius: blur * 0.7,
        ),
      ];
    } else {
      // Efek raised : dark di BR, light di TL
      shadows = [
        BoxShadow(
          color: _lightShadowColor,
          offset: Offset(-offset, -offset),
          blurRadius: blur,
        ),
        BoxShadow(
          color: _darkShadowColor,
          offset: Offset(offset, offset),
          blurRadius: blur,
        ),
      ];
    }

    // Gradient default kalau tidak di-set
    final effectiveGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pressed
              ? [
                  surfaceColor.withValues(alpha: 0.95),
                  surfaceColor,
                ]
              : [
                  surfaceColor.withValues(alpha: 1.0),
                  surfaceColor.withValues(alpha: 0.92),
                ],
          stops: pressed ? [0.0, 1.0] : [0.0, 1.0],
        );

    return Container(
      width: width,
      height: height,
      margin: margin,
      constraints: constraints,
      alignment: alignment,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: surfaceColor,
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 0.5)
            : null,
        boxShadow: shadows,
      ),
      child: Padding(
        padding: effectivePadding,
        child: effectiveChild,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/lumina_colors.dart';

class LuminaBackground extends StatelessWidget {
  const LuminaBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: -80,
          left: -40,
          child: _GlowOrb(
            size: 280,
            color: LuminaColors.primary,
            opacity: 0.1,
          ),
        ),
        const Positioned(
          bottom: -60,
          right: -30,
          child: _GlowOrb(
            size: 220,
            color: LuminaColors.secondary,
            opacity: 0.1,
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: 120,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

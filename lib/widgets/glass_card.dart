import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/lumina_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.isActive = false,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool isActive;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding,
          decoration: BoxDecoration(
            color: isActive
                ? LuminaColors.primaryContainer.withValues(alpha: 0.15)
                : LuminaColors.glassFill,
            borderRadius: borderRadius,
            border: Border.all(
              color: isActive
                  ? LuminaColors.primary.withValues(alpha: 0.6)
                  : LuminaColors.glassBorder,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: LuminaColors.primary.withValues(alpha: 0.2),
                      blurRadius: 40,
                      spreadRadius: -10,
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: content,
      ),
    );
  }
}

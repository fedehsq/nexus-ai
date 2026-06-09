import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/lumina_colors.dart';

class LuminaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LuminaAppBar({
    super.key,
    this.leading,
    this.onBack,
    this.title,
    this.subtitle,
    this.actions = const [],
    this.showBrand = false,
  });

  final Widget? leading;
  final VoidCallback? onBack;
  final String? title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBrand;

  static const double toolbarHeight = 64;

  static Widget backButton({required VoidCallback onPressed}) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: LuminaColors.primary),
      onPressed: onPressed,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  Widget? get _leading {
    if (leading != null) return leading;
    if (onBack != null) return backButton(onPressed: onBack!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AppBar(
          toolbarHeight: toolbarHeight,
          backgroundColor: LuminaColors.surface.withValues(alpha: 0.8),
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: _leading,
          title: showBrand
              ? _BrandTitle(subtitle: subtitle)
              : _TitleContent(title: title, subtitle: subtitle),
          actions: actions,
        ),
      ),
    );
  }
}

class _TitleContent extends StatelessWidget {
  const _TitleContent({this.title, this.subtitle});

  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    if (title == null && subtitle == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [LuminaColors.primary, LuminaColors.secondary],
            ).createShader(bounds),
            child: Text(
              title!,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.white),
            ),
          ),
        if (subtitle != null) ...[
          if (title != null) const SizedBox(height: 2),
          Text(subtitle!, style: Theme.of(context).textTheme.labelSmall),
        ],
      ],
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle({this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [LuminaColors.primary, LuminaColors.secondary],
          ).createShader(bounds),
          child: Text(
            'Nexus AI',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: LuminaColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: LuminaColors.success.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(subtitle!, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ],
    );
  }
}

class LuminaLogo extends StatelessWidget {
  const LuminaLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LuminaColors.primary, LuminaColors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: LuminaColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
          ),
        ],
      ),
      child: const Icon(
        Icons.hexagon_outlined,
        color: LuminaColors.onPrimary,
        size: 22,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/llm_model.dart';
import '../theme/lumina_colors.dart';
import 'glass_card.dart';

class LlmModelCard extends StatelessWidget {
  const LlmModelCard({
    super.key,
    required this.model,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
    this.featured = false,
    this.isDownloading = false,
    this.downloadProgress,
    this.onCancelDownload,
  });

  final LlmModel model;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;
  final bool featured;
  final bool isDownloading;
  final double? downloadProgress;
  final VoidCallback? onCancelDownload;

  @override
  Widget build(BuildContext context) {
    final icon = _iconForModel(model);
    final accent = _accentForModel(model);

    if (featured) {
      return GlassCard(
        isActive: isSelected,
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: LuminaColors.primary,
                            ),
                      ),
                      Text(
                        isDownloading
                            ? 'Download in corso...'
                            : (model.isDownloaded ? 'Pronto' : '${model.sizeMb} MB'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDownloading
                                  ? LuminaColors.primary
                                  : LuminaColors.tertiary,
                              letterSpacing: 1.2,
                            ),
                      ),
                    ],
                  ),
                ),
                if (model.isDownloaded)
                  const Icon(Icons.check_circle, color: LuminaColors.primary)
                else if (isDownloading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: LuminaColors.primary,
                    ),
                  ),
              ],
            ),
            if (isDownloading) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: downloadProgress?.clamp(0.0, 1.0),
                color: LuminaColors.primary,
                backgroundColor: LuminaColors.surfaceContainerHighest,
              ),
              if (downloadProgress != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${(downloadProgress! * 100).clamp(0, 100).toInt()}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: LuminaColors.primary,
                      ),
                ),
              ],
              if (onCancelDownload != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onCancelDownload,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Annulla'),
                    style: TextButton.styleFrom(
                      foregroundColor: LuminaColors.error,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 12),
            Text(
              model.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (model.supportsToolCalling)
                  _CapabilityChip(label: 'Tools', color: LuminaColors.primary),
                if (model.supportsVision)
                  _CapabilityChip(label: 'Vision', color: LuminaColors.secondary),
                if (model.supportsThinking)
                  _CapabilityChip(label: 'Thinking', color: LuminaColors.tertiary),
                if (model.requiresHighEndDevice)
                  _CapabilityChip(
                    label: '≥6 GB RAM',
                    color: LuminaColors.error.withValues(alpha: 0.85),
                  ),
                if (model.isDownloaded)
                  _CapabilityChip(label: 'Scaricato', color: LuminaColors.success),
                if (isDownloading)
                  _CapabilityChip(label: 'Download', color: LuminaColors.primary),
              ],
            ),
          ],
        ),
      );
    }

    return GlassCard(
      isActive: isSelected,
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 12 : 16),
      borderRadius: BorderRadius.circular(compact ? 16 : 24),
      child: Row(
        children: [
          Container(
            width: compact ? 40 : 48,
            height: compact ? 40 : 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: accent, size: compact ? 20 : 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: compact ? 16 : 20,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  isDownloading
                      ? 'Download in corso...'
                      : '${model.sizeMb} MB',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDownloading ? LuminaColors.primary : null,
                      ),
                ),
                if (isDownloading) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: downloadProgress?.clamp(0.0, 1.0),
                    color: LuminaColors.primary,
                    backgroundColor: LuminaColors.surfaceContainerHighest,
                  ),
                  if (onCancelDownload != null) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onCancelDownload,
                        icon: const Icon(Icons.close, size: 14),
                        label: const Text('Annulla'),
                        style: TextButton.styleFrom(
                          foregroundColor: LuminaColors.error,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ),
                    ),
                  ],
                ],
                if (!compact) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (model.supportsToolCalling)
                        const _CapabilityChip(
                          label: 'Tools',
                          color: LuminaColors.primary,
                        ),
                      if (model.supportsVision)
                        const _CapabilityChip(
                          label: 'Vision',
                          color: LuminaColors.secondary,
                        ),
                      if (model.requiresHighEndDevice)
                        _CapabilityChip(
                          label: '≥6 GB RAM',
                          color: LuminaColors.error.withValues(alpha: 0.85),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (model.isDownloaded)
            const Icon(Icons.check_circle, color: LuminaColors.primary)
          else if (isDownloading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: LuminaColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  static IconData _iconForModel(LlmModel model) {
    final name = model.name.toLowerCase();
    if (name.contains('code') || name.contains('gemma') && name.contains('it')) {
      return Icons.terminal;
    }
    if (model.supportsVision) return Icons.palette_outlined;
    if (model.supportsToolCalling) return Icons.hub_outlined;
    return Icons.model_training;
  }

  static Color _accentForModel(LlmModel model) {
    if (model.supportsVision) return LuminaColors.tertiary;
    if (model.supportsToolCalling) return LuminaColors.secondary;
    return LuminaColors.primary;
  }
}

class _CapabilityChip extends StatelessWidget {
  const _CapabilityChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

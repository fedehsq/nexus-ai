import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/llm_backend.dart';
import '../../providers/chat/chat_initialization_provider.dart';
import '../../providers/chat/chat_params_provider.dart';
import '../../providers/chat/chat_provider.dart';
import '../../providers/device/device_profile_provider.dart';
import '../../services/gemma_backend_selector.dart';
import '../../theme/lumina_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/lumina_app_bar.dart';
import '../../widgets/lumina_background.dart';

class ModelSettingsScreen extends ConsumerWidget {
  const ModelSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(chatParamsProvider);
    final selectedModel = ref.watch(selectedModelProvider);
    final engine = ref.watch(chatEngineProvider);
    final deviceProfileAsync = ref.watch(deviceProfileProvider);
    final deviceProfile = deviceProfileAsync.asData?.value;
    final backendReason = deviceProfile != null &&
            engine?.gemmaActiveBackend != null
        ? GemmaBackendSelector.backendReason(
            deviceProfile,
            engine!.gemmaActiveBackend,
          )
        : null;
    final notifier = ref.read(chatParamsProvider.notifier);

    return Scaffold(
      appBar: LuminaAppBar(
        title: 'Configurazione',
        onBack: () => context.pop(),
      ),
      body: LuminaBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Parametri del modello',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: LuminaColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Regola temperatura e lunghezza risposta per ${selectedModel?.name ?? 'il modello attivo'}.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (selectedModel?.backend == LlmBackend.flutterGemma &&
                engine?.gemmaActiveBackend != null) ...[
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.memory_outlined,
                      size: 20,
                      color: LuminaColors.primary.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Acceleratore attivo',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            GemmaBackendSelector.label(
                              engine!.gemmaActiveBackend,
                            ),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          if (backendReason != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              backendReason,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (selectedModel?.supportsWebSearch ?? false) ...[
                    _WebSearchToggle(
                      enabled: params.webSearchEnabled,
                      onChanged: notifier.setWebSearchEnabled,
                    ),
                    const SizedBox(height: 32),
                  ],
                  _SliderSection(
                    title: 'Creatività (Temperature)',
                    subtitle: 'Valori più alti = risposte più creative.',
                    valueLabel: params.temperature.toStringAsFixed(1),
                    value: params.temperature,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    leftLabel: 'Preciso',
                    rightLabel: 'Creativo',
                    onChanged: notifier.setTemperature,
                  ),
                  const SizedBox(height: 32),
                  _SliderSection(
                    title: 'Lunghezza risposta',
                    subtitle: 'Numero massimo di token per risposta.',
                    valueLabel: '${params.maxTokens}',
                    value: params.maxTokens.toDouble(),
                    min: 256,
                    max: 4096,
                    divisions: 15,
                    leftLabel: 'Breve',
                    rightLabel: 'Dettagliato',
                    onChanged: (v) => notifier.setMaxTokens(v.round()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebSearchToggle extends StatelessWidget {
  const _WebSearchToggle({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ricerca web',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Permette al modello di cercare informazioni aggiornate online '
                'quando necessario. Richiede connessione internet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Switch(
          value: enabled,
          activeThumbColor: LuminaColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SliderSection extends StatelessWidget {
  const _SliderSection({
    required this.title,
    required this.subtitle,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.leftLabel,
    required this.rightLabel,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String leftLabel;
  final String rightLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: LuminaColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(valueLabel, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leftLabel, style: Theme.of(context).textTheme.labelSmall),
            Text(rightLabel, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}


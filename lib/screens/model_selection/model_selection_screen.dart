import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/llm_model.dart';
import '../../models/model_download_state.dart';
import '../../models/models_state.dart';

import '../../providers/chat/chat_initialization_provider.dart';
import '../../providers/chat/chat_provider.dart';
import '../../providers/conversations/conversations_provider.dart';
import '../../providers/device/device_profile_provider.dart';
import '../../providers/models/cancel_model_download.dart';
import '../../providers/models/model_download_provider.dart';
import '../../providers/models/models_provider.dart';
import '../../router/routes.dart';
import '../../theme/lumina_colors.dart';
import '../../widgets/llm_model_card.dart';
import '../../widgets/lumina_app_bar.dart';
import '../../widgets/lumina_background.dart';

class ModelSelectionScreen extends ConsumerWidget {
  const ModelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModel = ref.watch(selectedModelProvider);
    final modelsState = ref.watch(modelsProvider);
    final downloadState = ref.watch(modelDownloadProvider);
    final hasHistory = ref.watch(conversationsProvider).isNotEmpty;

    ref.listen(modelsProvider, (previous, next) {
      if (next.hasError && previous?.hasError != next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: ${next.error}')),
        );
      }
    });

    return Scaffold(
      body: LuminaBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    if (hasHistory)
                      TextButton.icon(
                        onPressed: () => context.go(historyRoute),
                        icon: const Icon(Icons.history, size: 20),
                        label: const Text('Cronologia'),
                        style: TextButton.styleFrom(
                          foregroundColor: LuminaColors.onSurfaceVariant,
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const LuminaLogo(),
                    const SizedBox(width: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          LuminaColors.primary,
                          LuminaColors.secondary,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'Nexus AI',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildBody(
                  context,
                  ref,
                  modelsState,
                  selectedModel,
                  downloadState,
                ),
              ),
              _BottomBar(
                enabled: selectedModel != null &&
                    !(modelsState.value?.isDownloading ?? false) &&
                    !downloadState.isActive,
                isDownloading: (modelsState.value?.isDownloading ?? false) ||
                    downloadState.isActive,
                onPressed: selectedModel == null
                    ? null
                    : () => _onStart(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<ModelsState> modelsState,
    LlmModel? selectedModel,
    ModelDownloadState downloadState,
  ) {
    return modelsState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: LuminaColors.primary),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: LuminaColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Errore: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.read(modelsProvider.notifier).loadModels(),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
      ),
      data: (state) {
        if (state.models.isEmpty) {
          return const Center(child: Text('Nessun modello disponibile'));
        }

        return CustomScrollView(
          slivers: [
            const SliverPadding(padding: EdgeInsets.fromLTRB(16, 0, 16, 0)),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Text(
                    'Scegli la tua intelligenza',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Seleziona un modello Cactus per iniziare. Puoi cambiarlo in qualsiasi momento.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final model = state.models[index];
                  final isSelected = selectedModel?.slug == model.slug;
                  final isDownloading =
                      (downloadState.isActive &&
                          downloadState.modelSlug == model.slug) ||
                      (state.isDownloading &&
                          state.downloadingModelSlug == model.slug);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LlmModelCard(
                      model: model,
                      isSelected: isSelected,
                      featured: index == 0,
                      isDownloading: isDownloading,
                      downloadProgress: isDownloading
                          ? (downloadState.progress ?? state.downloadProgress)
                          : null,
                      onTap: downloadState.isActive
                          ? null
                          : () => _toggleModel(context, ref, model, isSelected),
                      onCancelDownload: isDownloading
                          ? () => _cancelDownload(context, ref)
                          : null,
                    ),
                  );
                },
                childCount: state.models.length,
              ),
            ),
            ),
          ],
        );
      },
    );
  }

  void _onStart(BuildContext context, WidgetRef ref) {
    ref.invalidate(chatInitializationProvider);
    ref.read(conversationsProvider.notifier).startNewConversation();
    ref.read(chatProvider.notifier).clearMessages();
    context.go(chatRoute);
  }

  Future<void> _toggleModel(
    BuildContext context,
    WidgetRef ref,
    LlmModel model,
    bool isSelected,
  ) async {
    if (isSelected) {
      ref.read(selectedModelProvider.notifier).setModel(null);
      return;
    }

    final profile = await ref.read(deviceProfileProvider.future);
    if (!context.mounted) return;

    if (!profile.canRunHeavyModels(
      modelRequiresHighEndDevice: model.requiresHighEndDevice,
    )) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Dispositivo con poca RAM'),
          content: Text(
            'Il tuo dispositivo ha ${profile.ramLabel} di RAM. '
            '${model.name} (~${model.sizeMb} MB) può chiudersi all\'improvviso '
            'durante il caricamento.\n\n'
            'Consigliamo un modello Cactus più leggero. Vuoi selezionarlo comunque?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Procedi'),
            ),
          ],
        ),
      );
      if (proceed != true || !context.mounted) return;
    }

    ref.read(selectedModelProvider.notifier).setModel(model);
  }

  Future<void> _cancelDownload(BuildContext context, WidgetRef ref) async {
    await cancelActiveModelDownload(ref);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download annullato')),
      );
    }
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.enabled,
    this.isDownloading = false,
    this.onPressed,
  });

  final bool enabled;
  final bool isDownloading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LuminaColors.surface.withValues(alpha: 0.85),
        border: Border(
          top: BorderSide(
            color: LuminaColors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: LuminaColors.primary,
            foregroundColor: LuminaColors.onPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isDownloading) ...[
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: LuminaColors.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Download in corso...',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ] else ...[
                const Text('Inizia', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


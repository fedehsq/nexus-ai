import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/llm_model.dart';
import '../../models/model_download_state.dart';

import '../../providers/chat/chat_initialization_provider.dart';
import '../../providers/chat/chat_provider.dart';
import '../../providers/models/cancel_model_download.dart';
import '../../providers/models/model_download_provider.dart';
import '../../widgets/glass_card.dart';
import '../../router/routes.dart';
import '../../theme/lumina_colors.dart';
import '../../widgets/chat_input_bar.dart';
import '../../widgets/chat_message_bubble.dart';
import '../../widgets/lumina_app_bar.dart';
import '../../widgets/lumina_background.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModel = ref.watch(selectedModelProvider);
    if (selectedModel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(modelSelectionRoute);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final initAsync = ref.watch(chatInitializationProvider);
    final engine = ref.watch(chatEngineProvider);

    return initAsync.when(
      loading: () => _LoadingScaffold(
        modelName: selectedModel.name,
        downloadState: ref.watch(modelDownloadProvider),
        onCancelDownload: () => _leaveDownloadScreen(context, ref),
      ),
      error: (error, _) => _ErrorScaffold(
        modelName: selectedModel.name,
        error: error,
        onRetry: () => ref.invalidate(chatInitializationProvider),
        onBack: () => context.go(modelSelectionRoute),
      ),
      data: (_) {
        if (engine == null || engine.modelSlug != selectedModel.slug) {
          return _StaleInitRecovery(
            modelName: selectedModel.name,
            downloadState: ref.watch(modelDownloadProvider),
            onCancelDownload: () => _leaveDownloadScreen(context, ref),
          );
        }
        return _ChatBody(model: selectedModel);
      },
    );
  }

  Future<void> _leaveDownloadScreen(BuildContext context, WidgetRef ref) async {
    await cancelActiveModelDownload(ref);
    if (!context.mounted) return;
    context.go(modelSelectionRoute);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(chatInitializationProvider);
    });
  }
}

class _StaleInitRecovery extends ConsumerStatefulWidget {
  const _StaleInitRecovery({
    required this.modelName,
    required this.downloadState,
    required this.onCancelDownload,
  });

  final String modelName;
  final ModelDownloadState downloadState;
  final Future<void> Function() onCancelDownload;

  @override
  ConsumerState<_StaleInitRecovery> createState() => _StaleInitRecoveryState();
}

class _StaleInitRecoveryState extends ConsumerState<_StaleInitRecovery> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(chatInitializationProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _LoadingScaffold(
      modelName: widget.modelName,
      downloadState: widget.downloadState,
      onCancelDownload: widget.onCancelDownload,
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold({
    required this.modelName,
    required this.downloadState,
    required this.onCancelDownload,
  });

  final String modelName;
  final ModelDownloadState downloadState;
  final Future<void> Function() onCancelDownload;

  @override
  Widget build(BuildContext context) {
    final status = downloadState.status.isNotEmpty
        ? downloadState.status
        : 'Download e inizializzazione modello...';
    final progress = downloadState.progress;
    final showProgress = downloadState.phase == ModelDownloadPhase.downloading ||
        downloadState.phase == ModelDownloadPhase.initializing;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        onCancelDownload();
      },
      child: Scaffold(
        appBar: LuminaAppBar(
          title: modelName,
          onBack: onCancelDownload,
        ),
        body: LuminaBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showProgress && progress == null)
                      const CircularProgressIndicator(
                        color: LuminaColors.primary,
                      )
                    else if (showProgress && progress != null) ...[
                      Text(
                        '${(progress * 100).clamp(0, 100).toInt()}%',
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: LuminaColors.primary,
                                ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        color: LuminaColors.primary,
                        backgroundColor: LuminaColors.surfaceContainerHighest,
                      ),
                    ] else
                      const CircularProgressIndicator(
                        color: LuminaColors.primary,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      status,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (downloadState.phase == ModelDownloadPhase.downloading ||
                        downloadState.phase == ModelDownloadPhase.initializing) ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: onCancelDownload,
                        icon: const Icon(Icons.close),
                        label: const Text('Annulla download'),
                        style: TextButton.styleFrom(
                          foregroundColor: LuminaColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({
    required this.modelName,
    required this.error,
    required this.onRetry,
    required this.onBack,
  });

  final String modelName;
  final Object error;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuminaAppBar(
        title: modelName,
        onBack: onBack,
      ),
      body: LuminaBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: LuminaColors.error, size: 48),
                const SizedBox(height: 16),
                Text('Errore: $error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: onRetry, child: const Text('Riprova')),
                TextButton(onPressed: onBack, child: const Text('Torna ai modelli')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatBody extends ConsumerStatefulWidget {
  const _ChatBody({required this.model});

  final LlmModel model;

  @override
  ConsumerState<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends ConsumerState<_ChatBody> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  DateTime? _lastScrollAt;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  void _scrollToBottomThrottled({required bool isLoading}) {
    final now = DateTime.now();
    final minInterval =
        isLoading ? const Duration(milliseconds: 250) : Duration.zero;
    if (_lastScrollAt != null &&
        now.difference(_lastScrollAt!) < minInterval) {
      return;
    }
    _lastScrollAt = now;
    _scrollToBottom(animated: !isLoading);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    ref.listen(chatProvider, (previous, next) {
      _scrollToBottomThrottled(isLoading: next.isLoading);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _leaveChat(context);
      },
      child: Scaffold(
        appBar: LuminaAppBar(
          title: widget.model.name,
          onBack: () => _leaveChat(context),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune, color: LuminaColors.primary),
              onPressed: () => context.push(settingsRoute),
            ),
          ],
        ),
        body: LuminaBackground(
          child: Column(
            children: [
              Expanded(
                child: chatState.messages.isEmpty
                    ? _EmptyChat(modelName: widget.model.name)
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: chatState.messages.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final isLast =
                              index == chatState.messages.length - 1;
                          return RepaintBoundary(
                            child: ChatMessageBubble(
                              message: chatState.messages[index],
                              isStreaming: isLast && chatState.isLoading,
                            ),
                          );
                        },
                      ),
              ),
              if (chatState.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(
                    color: LuminaColors.primary,
                    backgroundColor: LuminaColors.surfaceContainerHighest,
                  ),
                ),
              ChatInputBar(
                controller: _inputController,
                isLoading: chatState.isLoading,
                onSend: () {
                  final text = _inputController.text.trim();
                  if (text.isEmpty) return;
                  ref.read(chatProvider.notifier).addMessage(text).then((_) {
                    if (mounted) _inputController.clear();
                  }).catchError((Object error) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$error')),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _leaveChat(BuildContext context) {
    ref.read(chatProvider.notifier).stopActiveGeneration().then((_) {
      if (context.mounted) context.go(historyRoute);
    });
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.modelName});

  final String modelName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 48,
              color: LuminaColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Ciao! Sono Nexus AI',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Modello attivo: $modelName. Come posso aiutarti oggi?',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

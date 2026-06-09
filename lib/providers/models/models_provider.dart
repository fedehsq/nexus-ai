import 'package:cactus/cactus.dart' as cactus;
import 'package:flutter_gemma/core/model_management/cancel_token.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/llm_backend.dart';
import '../../models/llm_model.dart';
import '../../models/models_state.dart';
import '../../repositories/llm_models_repository.dart';
import 'model_download_provider.dart';

part 'models_provider.g.dart';

@riverpod
class Models extends _$Models {
  cactus.CactusLM? _lm;
  final _repository = LlmModelsRepository();

  @override
  Future<ModelsState> build() async {
    ref.onDispose(_disposeLm);
    return _fetchModels();
  }

  void _disposeLm() {
    _lm?.unload();
    _lm = null;
  }

  Future<ModelsState> _fetchModels() async {
    _lm ??= cactus.CactusLM();
    final models = await _repository.fetchAll(existingLm: _lm);
    return ModelsState.initial().copyWith(models: models);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchModels);
  }

  /// Kept for backward compatibility with existing UI call sites.
  Future<void> loadModels() => reload();

  void clearDownloadingState() {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        isDownloading: false,
        downloadStatus: '',
        downloadProgress: 0,
        clearDownloadingModelSlug: true,
      ),
    );
  }

  void markModelDownloaded(String slug) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        models: [
          for (final model in current.models)
            if (model.slug == slug) model.copyWith(isDownloaded: true) else model,
        ],
      ),
    );
  }

  Future<void> downloadModel(LlmModel model) async {
    final currentState = state.value ?? ModelsState.initial();
    final download = ref.read(modelDownloadProvider.notifier);

    state = AsyncData(
      currentState.copyWith(
        isDownloading: true,
        downloadProgress: 0,
        downloadStatus: 'Inizio download...',
        downloadingModelSlug: model.slug,
      ),
    );

    try {
      switch (model.backend) {
        case LlmBackend.cactus:
          _lm ??= cactus.CactusLM();
          await download.downloadCactusIfNeeded(
            lm: _lm!,
            modelSlug: model.slug,
          );
        case LlmBackend.flutterGemma:
          await download.ensureGemmaModelActive(modelSlug: model.slug);
      }

      final progress = ref.read(modelDownloadProvider);
      final current = state.value;
      if (current != null) {
        final updatedModels = current.models
            .map(
              (m) => m.slug == model.slug ? m.copyWith(isDownloaded: true) : m,
            )
            .toList();

        state = AsyncData(
          current.copyWith(
            models: updatedModels,
            isDownloading: false,
            downloadStatus: progress.status.isNotEmpty
                ? progress.status
                : 'Download completato',
            downloadProgress: 1,
            downloadingModelSlug: null,
          ),
        );
      }
      download.reset();
    } catch (e) {
      if (CancelToken.isCancel(e)) {
        clearDownloadingState();
        download.reset();
        return;
      }
      state = AsyncError(e, StackTrace.current);
      download.reset();
    }
  }
}

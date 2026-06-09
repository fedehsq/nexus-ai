import 'package:cactus/cactus.dart' as cactus;
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/flutter_gemma_model_catalog.dart';
import '../../models/model_download_state.dart';
import '../../services/cactus_model_download_service.dart';

part 'model_download_provider.g.dart';

@Riverpod(keepAlive: true)
class ModelDownload extends _$ModelDownload {
  CancelToken? _cancelToken;
  bool _cancellationRequested = false;

  @override
  ModelDownloadState build() => const ModelDownloadState();

  bool get isCancellationRequested => _cancellationRequested;

  void reset() {
    _cancelToken = null;
    _cancellationRequested = false;
    state = const ModelDownloadState();
  }

  Future<void> cancelDownload() async {
    _cancellationRequested = true;
    _cancelToken?.cancel('Annullato dall\'utente');
    CactusModelDownloadService.abort();
    _cancelToken = null;
    state = const ModelDownloadState();
  }

  void _beginOperation(String modelSlug) {
    _cancellationRequested = false;
    _cancelToken = CancelToken();
    state = ModelDownloadState(
      phase: ModelDownloadPhase.downloading,
      progress: 0,
      status: 'Preparazione download...',
      modelSlug: modelSlug,
    );
  }

  void _ensureNotCancelled() {
    _cancelToken?.throwIfCancelled();
    if (_cancellationRequested) {
      throw DownloadCancelledException('Annullato dall\'utente', null);
    }
  }

  /// Called by native download callbacks — must stay synchronous.
  void reportProgress(double? progress, String status, bool isError) {
    if (!ref.mounted || _cancellationRequested) return;

    state = state.copyWith(
      phase: isError ? ModelDownloadPhase.error : ModelDownloadPhase.downloading,
      progress: isError ? null : progress,
      status: status,
      clearProgress: isError,
    );
  }

  void setInitializing() {
    _ensureNotCancelled();
    state = state.copyWith(
      phase: ModelDownloadPhase.initializing,
      progress: null,
      status: 'Inizializzazione modello...',
      clearProgress: true,
    );
  }

  void markCompleted() {
    _ensureNotCancelled();
    state = state.copyWith(
      phase: ModelDownloadPhase.completed,
      progress: 1,
      status: 'Download completato',
    );
  }

  void _ensureNoFailure() {
    _ensureNotCancelled();
    if (state.hasFailed) {
      throw Exception(state.status);
    }
  }

  Future<void> downloadCactusIfNeeded({
    required cactus.CactusLM lm,
    required String modelSlug,
  }) async {
    if (await CactusModelDownloadService.isModelCached(modelSlug)) {
      return;
    }

    _beginOperation(modelSlug);

    try {
      await CactusModelDownloadService.downloadIfNeeded(
        lm: lm,
        modelSlug: modelSlug,
        onProgress: reportProgress,
        cancelToken: _cancelToken!,
      );
      _ensureNoFailure();
      markCompleted();
    } on DownloadCancelledException {
      rethrow;
    }
  }

  Future<void> ensureGemmaModelActive({required String modelSlug}) async {
    final entry = FlutterGemmaModelCatalog.bySlug(modelSlug);
    if (entry == null) {
      throw Exception('Modello Gemma non configurato: $modelSlug');
    }

    _beginOperation(modelSlug);

    try {
      await FlutterGemma.installModel(
        modelType: entry.modelType,
        fileType: ModelFileType.litertlm,
      )
          .fromNetwork(entry.downloadUrl)
          .withCancelToken(_cancelToken!)
          .withProgress((progress) {
            reportProgress(progress / 100, 'Download $progress%', false);
          })
          .install();

      _ensureNoFailure();
      markCompleted();
    } on DownloadCancelledException {
      rethrow;
    }
  }
}

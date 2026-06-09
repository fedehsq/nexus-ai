import 'package:flutter_gemma/core/model_management/cancel_token.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/chat_engine_state.dart';
import '../../services/chat_engine_initializer.dart';
import '../models/model_download_provider.dart';
import '../models/models_provider.dart';
import 'chat_params_provider.dart';
import 'chat_provider.dart';

part 'chat_initialization_provider.g.dart';

@Riverpod(keepAlive: true)
class ChatEngine extends _$ChatEngine {
  @override
  ChatEngineState? build() => null;

  void set(ChatEngineState? engine) {
    state = engine;
  }

  Future<void> disposeEngine() async {
    final engine = state;
    if (engine == null) return;

    engine.cactusLm?.unload();
    await engine.gemmaModel?.close();
    state = null;
  }
}

@Riverpod(keepAlive: true)
Future<void> chatInitialization(Ref ref) async {
  final model = ref.read(selectedModelProvider);
  if (model == null) {
    throw Exception('Nessun modello selezionato');
  }

  final currentEngine = ref.read(chatEngineProvider);
  if (currentEngine?.modelSlug == model.slug) return;

  // First await exits the synchronous provider build phase.
  await ref.read(chatEngineProvider.notifier).disposeEngine();

  final download = ref.read(modelDownloadProvider.notifier);
  final params = ref.read(chatParamsProvider);

  try {
    final engine = await ChatEngineInitializer.initialize(
      model: model,
      maxTokens: params.maxTokens,
      downloadCactus: download.downloadCactusIfNeeded,
      activateGemma: download.ensureGemmaModelActive,
      onInitializing: download.setInitializing,
    );

    if (download.isCancellationRequested) {
      engine.cactusLm?.unload();
      await engine.gemmaModel?.close();
      throw DownloadCancelledException('Annullato dall\'utente', null);
    }

    ref.read(chatEngineProvider.notifier).set(engine);
    ref.read(selectedModelProvider.notifier).markDownloaded();
    ref.read(modelsProvider.notifier).markModelDownloaded(model.slug);
    download.reset();
  } on DownloadCancelledException {
    rethrow;
  } catch (e) {
    if (download.isCancellationRequested || CancelToken.isCancel(e)) {
      throw DownloadCancelledException('Annullato dall\'utente', null);
    }
    download.reportProgress(null, e.toString(), true);
    rethrow;
  }
}

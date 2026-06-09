import 'package:cactus/cactus.dart' as cactus;

import '../models/chat_engine_state.dart';
import '../models/llm_backend.dart';
import '../models/llm_model.dart';
import 'llm_inference_service.dart';

/// Downloads (if needed) and initializes the inference engine for a model.
abstract final class ChatEngineInitializer {
  static Future<ChatEngineState> initialize({
    required LlmModel model,
    required int maxTokens,
    required Future<void> Function({
      required cactus.CactusLM lm,
      required String modelSlug,
    }) downloadCactus,
    required Future<void> Function({required String modelSlug}) activateGemma,
    required void Function() onInitializing,
  }) async {
    return switch (model.backend) {
      LlmBackend.cactus => _initializeCactus(
          model: model,
          downloadCactus: downloadCactus,
          onInitializing: onInitializing,
        ),
      LlmBackend.flutterGemma => _initializeGemma(
          model: model,
          maxTokens: maxTokens,
          activateGemma: activateGemma,
          onInitializing: onInitializing,
        ),
    };
  }

  static Future<ChatEngineState> _initializeCactus({
    required LlmModel model,
    required Future<void> Function({
      required cactus.CactusLM lm,
      required String modelSlug,
    }) downloadCactus,
    required void Function() onInitializing,
  }) async {
    final lm = cactus.CactusLM(enableToolFiltering: false);

    await downloadCactus(lm: lm, modelSlug: model.slug);

    onInitializing();
    await lm.initializeModel(
      params: cactus.CactusInitParams(model: model.slug),
    );

    return ChatEngineState(
      modelSlug: model.slug,
      backend: LlmBackend.cactus,
      cactusLm: lm,
    );
  }

  static Future<ChatEngineState> _initializeGemma({
    required LlmModel model,
    required int maxTokens,
    required Future<void> Function({required String modelSlug}) activateGemma,
    required void Function() onInitializing,
  }) async {
    await activateGemma(modelSlug: model.slug);

    onInitializing();
    final gemma = await LlmInferenceService.createGemmaModel(
      model: model,
      maxTokens: maxTokens,
    );

    return ChatEngineState(
      modelSlug: model.slug,
      backend: LlmBackend.flutterGemma,
      gemmaModel: gemma.model,
      gemmaActiveBackend: gemma.activeBackend,
    );
  }
}

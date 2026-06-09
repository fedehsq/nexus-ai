import 'package:cactus/cactus.dart' as cactus;
import 'package:flutter_gemma/flutter_gemma.dart';

import '../data/flutter_gemma_model_catalog.dart';
import '../models/chat_message.dart';
import '../models/chat_params.dart';
import '../models/inference_stream_update.dart';
import '../models/llm_backend.dart';
import '../models/llm_model.dart';
import 'chat_tool_executor.dart';
import 'device_profile_service.dart';
import 'gemma_backend_selector.dart';
import 'inference/cactus_inference_handler.dart';
import 'inference/gemma_inference_handler.dart';

/// Facade over backend-specific streaming handlers (Cactus / Gemma).
class LlmInferenceService {
  LlmInferenceService({ChatToolExecutor? toolExecutor})
      : _cactus = CactusInferenceHandler(toolExecutor ?? ChatToolExecutor()),
        _gemma = GemmaInferenceHandler(toolExecutor ?? ChatToolExecutor());

  final CactusInferenceHandler _cactus;
  final GemmaInferenceHandler _gemma;

  Stream<InferenceStreamUpdate> streamCompletion({
    required LlmModel model,
    required cactus.CactusLM? cactusLm,
    required InferenceModel? gemmaModel,
    required List<AppChatMessage> messages,
    required ChatParams params,
  }) {
    final useTools = params.webSearchEnabled && model.supportsWebSearch;

    return switch (model.backend) {
      LlmBackend.cactus => _cactus.stream(
          lm: cactusLm!,
          messages: messages,
          params: params,
          useTools: useTools,
        ),
      LlmBackend.flutterGemma => _gemma.stream(
          model: gemmaModel!,
          llmModel: model,
          messages: messages,
          useWebSearch: useTools,
        ),
    };
  }

  static Future<({InferenceModel model, PreferredBackend? activeBackend})>
      createGemmaModel({
    required LlmModel model,
    required int maxTokens,
  }) async {
    final entry = FlutterGemmaModelCatalog.bySlug(model.slug);
    if (entry == null) {
      throw Exception('Configurazione Gemma non trovata per ${model.slug}');
    }

    final profile = await DeviceProfileService.load();
    final preferredBackend = GemmaBackendSelector.preferredFor(profile);

    final inferenceModel = await FlutterGemma.getActiveModel(
      maxTokens: maxTokens,
      preferredBackend: preferredBackend,
      supportImage: entry.supportsVision,
      supportAudio: entry.supportsAudio,
    );

    return (
      model: inferenceModel,
      activeBackend: inferenceModel.activeBackend,
    );
  }
}

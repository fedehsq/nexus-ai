import 'package:cactus/cactus.dart' as cactus;
import 'package:flutter_gemma/flutter_gemma.dart';

import 'llm_backend.dart';

/// Runtime handles required to run inference for the active model.
class ChatEngineState {
  const ChatEngineState({
    required this.modelSlug,
    required this.backend,
    this.cactusLm,
    this.gemmaModel,
    this.gemmaActiveBackend,
  });

  final String modelSlug;
  final LlmBackend backend;
  final cactus.CactusLM? cactusLm;
  final InferenceModel? gemmaModel;

  /// Actual accelerator selected by LiteRT after fallback (Gemma only).
  final PreferredBackend? gemmaActiveBackend;
}

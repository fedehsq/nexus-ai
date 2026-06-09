import 'package:flutter_gemma/flutter_gemma.dart';

import '../models/llm_backend.dart';
import '../models/llm_model.dart';

class FlutterGemmaModelEntry {
  const FlutterGemmaModelEntry({
    required this.slug,
    required this.name,
    required this.sizeMb,
    required this.downloadUrl,
    required this.installFileName,
    required this.modelType,
    required this.description,
    this.supportsToolCalling = false,
    this.supportsVision = false,
    this.supportsAudio = false,
    this.supportsThinking = false,
  });

  final String slug;
  final String name;
  final int sizeMb;
  final String downloadUrl;
  final String installFileName;
  final ModelType modelType;
  final String description;
  final bool supportsToolCalling;
  final bool supportsVision;
  final bool supportsAudio;
  final bool supportsThinking;

  LlmModel toLlmModel({required bool isDownloaded}) {
    return LlmModel(
      slug: slug,
      name: name,
      sizeMb: sizeMb,
      backend: LlmBackend.flutterGemma,
      description: description,
      supportsToolCalling: supportsToolCalling,
      supportsVision: supportsVision,
      supportsThinking: supportsThinking,
      supportsAudio: supportsAudio,
      isDownloaded: isDownloaded,
    );
  }
}

abstract final class FlutterGemmaModelCatalog {
  static const _gemma4E2bUrl =
      'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm';
  static const _gemma4E4bUrl =
      'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it.litertlm';

  static const models = <FlutterGemmaModelEntry>[
    FlutterGemmaModelEntry(
      slug: 'gemma-4-e2b-it',
      name: 'Gemma 4 E2B IT',
      sizeMb: 2400,
      downloadUrl: _gemma4E2bUrl,
      installFileName: 'gemma-4-E2B-it.litertlm',
      modelType: ModelType.gemma4,
      description:
          'Multimodale on-device (testo, immagine, audio) ottimizzato per dispositivi ARM.',
      supportsToolCalling: true,
      supportsVision: true,
      supportsAudio: true,
      supportsThinking: true,
    ),
    FlutterGemmaModelEntry(
      slug: 'gemma-4-e4b-it',
      name: 'Gemma 4 E4B IT',
      sizeMb: 4300,
      downloadUrl: _gemma4E4bUrl,
      installFileName: 'gemma-4-E4B-it.litertlm',
      modelType: ModelType.gemma4,
      description:
          'Modello Gemma 4 più capace, multimodale e ottimizzato per dispositivi.',
      supportsToolCalling: true,
      supportsVision: true,
      supportsAudio: true,
      supportsThinking: true,
    ),
  ];

  static FlutterGemmaModelEntry? bySlug(String slug) {
    for (final entry in models) {
      if (entry.slug == slug) return entry;
    }
    return null;
  }
}

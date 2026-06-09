import 'llm_backend.dart';

class LlmModel {
  const LlmModel({
    required this.slug,
    required this.name,
    required this.sizeMb,
    required this.backend,
    required this.supportsToolCalling,
    required this.supportsVision,
    this.description = '',
    this.supportsThinking = false,
    this.supportsAudio = false,
    this.isDownloaded = false,
  });

  final String slug;
  final String name;
  final int sizeMb;
  final LlmBackend backend;
  final String description;
  final bool supportsToolCalling;
  final bool supportsVision;
  final bool supportsThinking;
  final bool supportsAudio;
  final bool isDownloaded;

  /// Large on-device models need several GB of free RAM at runtime.
  bool get requiresHighEndDevice => sizeMb >= 2000;

  /// Web search via native tool calling (excludes Cactus models that only
  /// advertise tools in catalog but fail in the native engine, e.g. FunctionGemma).
  bool get supportsWebSearch {
    if (!supportsToolCalling) return false;

    return switch (backend) {
      LlmBackend.flutterGemma => true,
      LlmBackend.cactus => _cactusSupportsNativeToolCalling(slug),
    };
  }

  static bool _cactusSupportsNativeToolCalling(String slug) {
    final normalized = slug.toLowerCase();
    if (normalized.contains('functiongemma') ||
        normalized.contains('function-gemma') ||
        normalized.contains('gemma')) {
      return false;
    }

    return normalized.contains('lfm') ||
        normalized.contains('liquid') ||
        normalized.contains('qwen') ||
        normalized.contains('youtu') ||
        normalized.contains('smol');
  }

  LlmModel copyWith({bool? isDownloaded}) {
    return LlmModel(
      slug: slug,
      name: name,
      sizeMb: sizeMb,
      backend: backend,
      description: description,
      supportsToolCalling: supportsToolCalling,
      supportsVision: supportsVision,
      supportsThinking: supportsThinking,
      supportsAudio: supportsAudio,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }
}

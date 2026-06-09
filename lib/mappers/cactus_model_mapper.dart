import 'package:cactus/cactus.dart' as cactus;

import '../models/llm_backend.dart';
import '../models/llm_model.dart';

abstract final class CactusModelMapper {
  static LlmModel toDomain(cactus.CactusModel model) {
    return LlmModel(
      slug: model.slug,
      name: model.name,
      sizeMb: model.sizeMb,
      backend: LlmBackend.cactus,
      description: _descriptionFor(model),
      supportsToolCalling: model.supportsToolCalling,
      supportsVision: model.supportsVision,
      isDownloaded: model.isDownloaded,
    );
  }

  static bool isChatModel(cactus.CactusModel model) {
    final slug = model.slug.toLowerCase();
    final name = model.name.toLowerCase();
    return !slug.contains('embed') && !name.contains('embed');
  }

  static String _descriptionFor(cactus.CactusModel model) {
    if (model.supportsVision && model.supportsToolCalling) {
      return 'Modello multimodale con supporto strumenti, ottimizzato per Cactus su dispositivo.';
    }
    if (model.supportsToolCalling) {
      return 'Ottimizzato per ragionamento, tool calling e compiti tecnici su dispositivo.';
    }
    return 'Modello leggero per chat veloce e uso quotidiano in locale.';
  }
}

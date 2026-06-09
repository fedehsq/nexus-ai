import 'package:cactus/cactus.dart' as cactus;
import 'package:flutter_gemma/core/api/flutter_gemma.dart';

import '../data/flutter_gemma_model_catalog.dart';
import '../mappers/cactus_model_mapper.dart';
import '../models/llm_model.dart';

class LlmModelsRepository {
  Future<List<LlmModel>> fetchAll({cactus.CactusLM? existingLm}) async {
    final lm = existingLm ?? cactus.CactusLM();
    final cactusModels = await lm.getModels();
    final cactusChatModels = cactusModels
        .where(CactusModelMapper.isChatModel)
        .map(CactusModelMapper.toDomain)
        .toList();

    final cactusSlugs = cactusChatModels.map((m) => _normalizeSlug(m.slug)).toSet();

    final gemmaModels = <LlmModel>[];
    for (final entry in FlutterGemmaModelCatalog.models) {
      if (cactusSlugs.contains(_normalizeSlug(entry.slug))) continue;
      final installed = await FlutterGemma.isModelInstalled(entry.installFileName);
      gemmaModels.add(entry.toLlmModel(isDownloaded: installed));
    }

    return [...gemmaModels, ...cactusChatModels];
  }

  static String _normalizeSlug(String slug) {
    return slug.toLowerCase().replaceAll(RegExp(r'[_\-.]'), '');
  }
}

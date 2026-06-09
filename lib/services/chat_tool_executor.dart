import 'dart:convert';

import 'package:cactus/cactus.dart' as cactus;
import 'package:flutter_gemma/flutter_gemma.dart';

import '../data/chat_tools.dart';
import 'web_search_service.dart';

class ChatToolExecutor {
  ChatToolExecutor({WebSearchService? webSearchService})
      : _webSearch = webSearchService ?? WebSearchService();

  final WebSearchService _webSearch;

  Future<Map<String, dynamic>> executeCactus(cactus.ToolCall call) async {
    switch (call.name) {
      case ChatTools.webSearchName:
        return _runWebSearch(call.arguments['query']);
      default:
        return {'status': 'error', 'message': 'Tool sconosciuto: ${call.name}'};
    }
  }

  Future<String> executeCactusAsJson(cactus.ToolCall call) async {
    return jsonEncode(await executeCactus(call));
  }

  Future<Map<String, dynamic>> executeGemma(FunctionCallResponse call) async {
    switch (call.name) {
      case ChatTools.webSearchName:
        final query = call.args['query']?.toString();
        return _runWebSearch(query);
      default:
        return {'status': 'error', 'message': 'Tool sconosciuto: ${call.name}'};
    }
  }

  Future<Map<String, dynamic>> _runWebSearch(String? query) async {
    if (query == null || query.trim().isEmpty) {
      return {
        'status': 'error',
        'message': 'Parametro query mancante o vuoto.',
      };
    }

    try {
      final results = await _webSearch.search(query);
      return _webSearch.formatForTool(results);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Errore durante la ricerca web: $e',
      };
    }
  }
}

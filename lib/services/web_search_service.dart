import 'package:dio/dio.dart';

import '../models/web_search_result.dart';
import '../utils/external_url_resolver.dart';

class WebSearchService {
  WebSearchService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _userAgent =
      'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36';

  Future<List<WebSearchResult>> search(String query, {int limit = 5}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final response = await _dio.get<String>(
      'https://lite.duckduckgo.com/lite/',
      queryParameters: {'q': trimmed},
      options: Options(
        responseType: ResponseType.plain,
        headers: {'User-Agent': _userAgent},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('Ricerca web non disponibile (${response.statusCode})');
    }

    return _parseLiteHtml(response.data!, limit: limit);
  }

  List<WebSearchResult> _parseLiteHtml(String html, {required int limit}) {
    final results = <WebSearchResult>[];
    final linkPattern = RegExp(
      r'<a[^>]+rel="nofollow"[^>]+href="([^"]+)"[^>]*>([^<]+)</a>',
      caseSensitive: false,
    );
    final snippetPattern = RegExp(
      r'<td[^>]*class="result-snippet"[^>]*>([\s\S]*?)</td>',
      caseSensitive: false,
    );

    final links = linkPattern.allMatches(html).toList();
    final snippets = snippetPattern.allMatches(html).toList();

    for (var i = 0; i < links.length && results.length < limit; i++) {
      final linkMatch = links[i];
      final rawUrl = _decodeHtmlEntities(linkMatch.group(1) ?? '');
      final title = _decodeHtmlEntities(linkMatch.group(2) ?? '').trim();
      if (title.isEmpty || rawUrl.isEmpty) continue;

      final url = ExternalUrlResolver.resolve(rawUrl);
      if (!ExternalUrlResolver.isValidHttpUrl(url)) continue;

      final snippet = i < snippets.length
          ? _stripHtml(_decodeHtmlEntities(snippets[i].group(1) ?? ''))
          : '';

      results.add(
        WebSearchResult(
          title: title,
          url: url,
          snippet: snippet,
        ),
      );
    }

    return results;
  }

  String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _decodeHtmlEntities(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  Map<String, dynamic> formatForTool(List<WebSearchResult> results) {
    if (results.isEmpty) {
      return {
        'status': 'no_results',
        'message': 'Nessun risultato trovato.',
        'results': <Map<String, dynamic>>[],
      };
    }

    return {
      'status': 'success',
      'results': results.map((r) => r.toJson()).toList(),
    };
  }
}

/// Parses model "thinking" blocks from streamed assistant output.
class ThinkingParseResult {
  const ThinkingParseResult({
    this.reasoning,
    required this.response,
    this.isReasoningInProgress = false,
  });

  final String? reasoning;
  final String response;
  final bool isReasoningInProgress;

  bool get hasReasoning => reasoning != null && reasoning!.trim().isNotEmpty;
}

abstract final class ThinkingParser {
  static final _endTokenPattern = RegExp(r'<\|im_end\|>|</s>');

  static final _completeBlocks = [
    _TagPair(
      open: RegExp(r'<think>', caseSensitive: false),
      close: RegExp(r'</think>', caseSensitive: false),
    ),
    _TagPair(
      open: RegExp(r'<thinking>', caseSensitive: false),
      close: RegExp(r'</thinking>', caseSensitive: false),
    ),
  ];

  static final _openBlocks = [
    RegExp(r'<think>(.*)', caseSensitive: false, dotAll: true),
    RegExp(r'<thinking>(.*)', caseSensitive: false, dotAll: true),
  ];

  static ThinkingParseResult parse(String raw) {
    final content = raw.replaceAll(_endTokenPattern, '').trim();

    for (final pair in _completeBlocks) {
      final match = pair.completePattern.firstMatch(content);
      if (match != null) {
        final reasoning = match.group(1)?.trim();
        final response = content.replaceRange(match.start, match.end, '').trim();
        return ThinkingParseResult(
          reasoning: reasoning?.isEmpty == true ? null : reasoning,
          response: response,
        );
      }
    }

    for (final openPattern in _openBlocks) {
      final match = openPattern.firstMatch(content);
      if (match != null) {
        final reasoning = match.group(1)?.trim() ?? '';
        final before = content.substring(0, match.start).trim();
        return ThinkingParseResult(
          reasoning: reasoning.isEmpty ? null : reasoning,
          response: before,
          isReasoningInProgress: true,
        );
      }
    }

    return _splitPlainReasoning(content);
  }

  /// Gemma and other models sometimes emit unstructured numbered reasoning
  /// before the actual answer (without XML-style tags).
  static ThinkingParseResult _splitPlainReasoning(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return const ThinkingParseResult(response: '');
    }

    final lines = trimmed.split('\n');
    var numberedLines = 0;
    var lastNumberedIndex = -1;

    for (var i = 0; i < lines.length; i++) {
      if (_numberedStepPattern.hasMatch(lines[i].trim())) {
        numberedLines++;
        lastNumberedIndex = i;
      }
    }

    if (numberedLines < 2) {
      return ThinkingParseResult(response: trimmed);
    }

    for (var i = lastNumberedIndex + 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      if (_numberedStepPattern.hasMatch(line)) continue;

      final reasoning = lines.sublist(0, i).join('\n').trim();
      final response = lines.sublist(i).join('\n').trim();
      if (reasoning.length >= 60 && response.isNotEmpty) {
        return ThinkingParseResult(
          reasoning: reasoning,
          response: response,
        );
      }
      break;
    }

    if (numberedLines >= 2 && trimmed.length >= 80) {
      return ThinkingParseResult(
        reasoning: trimmed,
        response: '',
        isReasoningInProgress: true,
      );
    }

    return ThinkingParseResult(response: trimmed);
  }

  static final _numberedStepPattern = RegExp(r'^\d+\.\s+\S');
}

class _TagPair {
  _TagPair({required RegExp open, required RegExp close})
      : completePattern = RegExp(
          '${open.pattern}(.*?)${close.pattern}',
          caseSensitive: false,
          dotAll: true,
        );

  final RegExp completePattern;
}

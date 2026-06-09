import 'dart:convert';

import 'package:cactus/cactus.dart' as cactus;

/// LFM / Qwen tool-turn formatting for the Cactus native engine.
abstract final class CactusToolLoop {
  static List<cactus.ToolCall> extractToolCalls(
    cactus.CactusCompletionResult result,
  ) {
    if (result.toolCalls.isNotEmpty) return result.toolCalls;
    return _parseLfmToolCalls(result.response);
  }

  static String formatAssistantToolCalls(
    List<cactus.ToolCall> calls, {
    String? rawResponse,
  }) {
    if (calls.isEmpty) return rawResponse ?? '';

    if (rawResponse != null && rawResponse.contains('<|tool_call_start|>')) {
      return rawResponse;
    }

    final segments = calls.map(_formatLfmToolCall).join('');
    return '<|tool_call_start|>$segments<|tool_call_end|>';
  }

  static String formatToolResultMessage(
    cactus.ToolCall call,
    Map<String, dynamic> result,
  ) {
    return jsonEncode({
      'name': call.name,
      'content': _formatToolResultContent(result),
    });
  }

  static List<cactus.ToolCall> _parseLfmToolCalls(String text) {
    final pattern = RegExp(
      r'<\|tool_call_start\|>\[?(\w+)\((.*?)\)\]?<\|redacted_tool_call_end_kimi\|>',
      dotAll: true,
    );
    final calls = <cactus.ToolCall>[];

    for (final match in pattern.allMatches(text)) {
      final name = match.group(1);
      final argsRaw = match.group(2);
      if (name == null || argsRaw == null) continue;

      calls.add(
        cactus.ToolCall(
          name: name,
          arguments: _parseLfmArguments(argsRaw),
        ),
      );
    }

    return calls;
  }

  static String _formatLfmToolCall(cactus.ToolCall call) {
    if (call.arguments.isEmpty) return '${call.name}()';

    final args = call.arguments.entries
        .map((entry) => '${entry.key}="${entry.value}"')
        .join(', ');
    return '${call.name}($args)';
  }

  static Map<String, String> _parseLfmArguments(String argsRaw) {
    final arguments = <String, String>{};
    final pattern = RegExp(r'(\w+)="([^"]*)"');

    for (final match in pattern.allMatches(argsRaw)) {
      final key = match.group(1);
      final value = match.group(2);
      if (key == null || value == null) continue;
      arguments[key] = value;
    }

    return arguments;
  }

  static String _formatToolResultContent(Map<String, dynamic> result) {
    final status = result['status'];
    if (status == 'success' && result['results'] is List) {
      final lines = <String>[];
      for (final item in result['results']) {
        if (item is! Map) continue;
        final title = item['title']?.toString() ?? '';
        final snippet = item['snippet']?.toString() ?? '';
        final url = item['url']?.toString() ?? '';
        if (title.isEmpty) continue;
        lines.add('$title: $snippet ($url)');
      }
      if (lines.isNotEmpty) return lines.join('\n');
    }

    final message = result['message']?.toString();
    if (message != null && message.isNotEmpty) return message;

    return jsonEncode(result);
  }
}

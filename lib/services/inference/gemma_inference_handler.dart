import 'package:flutter_gemma/flutter_gemma.dart';

import '../../data/chat_tools.dart';
import '../../data/flutter_gemma_model_catalog.dart';
import '../../mappers/chat_message_mapper.dart';
import '../../models/chat_message.dart';
import '../../models/inference_stream_update.dart';
import '../../models/llm_model.dart';
import '../../utils/thinking_parser.dart';
import '../chat_tool_executor.dart';
import 'inference_constants.dart';

/// Streaming inference for flutter_gemma models, with optional tool-calling loop.
class GemmaInferenceHandler {
  const GemmaInferenceHandler(this._tools);

  final ChatToolExecutor _tools;

  Stream<InferenceStreamUpdate> stream({
    required InferenceModel model,
    required LlmModel llmModel,
    required List<AppChatMessage> messages,
    required bool useWebSearch,
  }) async* {
    final entry = FlutterGemmaModelCatalog.bySlug(llmModel.slug);
    final chat = await model.createChat(
      supportsFunctionCalls: useWebSearch,
      tools: useWebSearch ? ChatTools.gemmaTools : const [],
      modelType: entry?.modelType ?? ModelType.gemmaIt,
      isThinking: entry?.supportsThinking ?? false,
      supportImage: entry?.supportsVision ?? false,
      supportAudio: entry?.supportsAudio ?? false,
    );

    try {
      await ChatMessageMapper.seedGemmaHistory(chat, messages);

      var notifiedSearch = false;

      for (var i = 0; i < InferenceConstants.maxToolIterations; i++) {
        final turn = await _consumeStream(chat);

        if (turn.functionCall != null) {
          if (!notifiedSearch) {
            notifiedSearch = true;
            yield const InferenceStreamUpdate(
              response: InferenceConstants.searchStatusMessage,
            );
          }
          await _submitToolResult(chat, turn.functionCall!);
          continue;
        }

        if (turn.parallelCalls != null) {
          if (!notifiedSearch) {
            notifiedSearch = true;
            yield const InferenceStreamUpdate(
              response: InferenceConstants.searchStatusMessage,
            );
          }
          for (final call in turn.parallelCalls!.calls) {
            await _submitToolResult(chat, call);
          }
          continue;
        }

        for (final update in turn.updates) {
          yield update;
        }

        if (turn.completed) return;
      }
    } finally {
      await chat.session.close();
    }
  }

  Future<_GemmaTurnResult> _consumeStream(InferenceChat chat) async {
    var reasoning = '';
    var response = '';
    var hasText = false;
    FunctionCallResponse? functionCall;
    ParallelFunctionCallResponse? parallelCalls;
    final updates = <InferenceStreamUpdate>[];

    await for (final event in chat.generateChatResponseAsync()) {
      switch (event) {
        case TextResponse(:final token):
          hasText = true;
          response += token;
          final parsed = ThinkingParser.parse(response);
          updates.add(
            InferenceStreamUpdate(
              response: parsed.response,
              reasoning: _mergeReasoning(reasoning, parsed.reasoning),
            ),
          );
        case ThinkingResponse(:final content):
          hasText = true;
          reasoning += content;
          updates.add(
            InferenceStreamUpdate(
              response: response,
              reasoning: reasoning.trim().isEmpty ? null : reasoning.trim(),
              isReasoningInProgress: true,
            ),
          );
        case FunctionCallResponse call:
          functionCall = call;
        case ParallelFunctionCallResponse calls:
          parallelCalls = calls;
      }
    }

    return _GemmaTurnResult(
      updates: updates,
      functionCall: functionCall,
      parallelCalls: parallelCalls,
      completed: hasText &&
          functionCall == null &&
          parallelCalls == null,
    );
  }

  Future<void> _submitToolResult(
    InferenceChat chat,
    FunctionCallResponse call,
  ) async {
    final result = await _tools.executeGemma(call);
    await chat.addQuery(
      Message.toolResponse(toolName: call.name, response: result),
    );
  }

  String? _mergeReasoning(String primary, String? secondary) {
    final a = primary.trim();
    final b = secondary?.trim();
    if (a.isEmpty && (b == null || b.isEmpty)) return null;
    if (a.isEmpty) return b;
    if (b == null || b.isEmpty) return a;
    if (a.contains(b) || b.contains(a)) {
      return a.length >= b.length ? a : b;
    }
    return '$a\n$b';
  }
}

class _GemmaTurnResult {
  const _GemmaTurnResult({
    required this.updates,
    required this.completed,
    this.functionCall,
    this.parallelCalls,
  });

  final List<InferenceStreamUpdate> updates;
  final bool completed;
  final FunctionCallResponse? functionCall;
  final ParallelFunctionCallResponse? parallelCalls;
}

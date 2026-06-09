import 'package:cactus/cactus.dart' as cactus;

import '../../data/chat_tools.dart';
import '../../mappers/chat_message_mapper.dart';
import '../../models/chat_message.dart';
import '../../models/chat_params.dart';
import '../../models/inference_stream_update.dart';
import '../../utils/thinking_parser.dart';
import '../chat_tool_executor.dart';
import 'cactus_tool_loop.dart';
import 'inference_constants.dart';

/// Streaming inference for Cactus models, with optional native tool calling.
class CactusInferenceHandler {
  const CactusInferenceHandler(this._tools);

  final ChatToolExecutor _tools;

  Stream<InferenceStreamUpdate> stream({
    required cactus.CactusLM lm,
    required List<AppChatMessage> messages,
    required ChatParams params,
    required bool useTools,
  }) {
    if (useTools) {
      return _streamWithTools(lm: lm, messages: messages, params: params);
    }
    return _streamPlain(lm: lm, messages: messages, params: params);
  }

  Stream<InferenceStreamUpdate> _streamPlain({
    required cactus.CactusLM lm,
    required List<AppChatMessage> messages,
    required ChatParams params,
  }) {
    return _streamCactusMessages(
      lm: lm,
      cactusMessages: ChatMessageMapper.toCactus(messages),
      params: params,
    );
  }

  Stream<InferenceStreamUpdate> _streamCactusMessages({
    required cactus.CactusLM lm,
    required List<cactus.ChatMessage> cactusMessages,
    required ChatParams params,
    List<cactus.CactusTool>? tools,
  }) async* {
    final streamed = await lm.generateCompletionStream(
      messages: cactusMessages,
      params: cactus.CactusCompletionParams(
        maxTokens: params.maxTokens,
        temperature: params.temperature,
        tools: tools,
      ),
    );

    var buffer = '';
    await for (final chunk in streamed.stream) {
      buffer += chunk;
      yield InferenceStreamUpdate.fromParsed(ThinkingParser.parse(buffer));
    }
  }

  Stream<InferenceStreamUpdate> _streamWithTools({
    required cactus.CactusLM lm,
    required List<AppChatMessage> messages,
    required ChatParams params,
  }) async* {
    var cactusMessages = ChatMessageMapper.toCactus(messages);
    var notifiedSearch = false;

    for (var i = 0; i < InferenceConstants.maxToolIterations; i++) {
      final result = await lm.generateCompletion(
        messages: cactusMessages,
        params: cactus.CactusCompletionParams(
          maxTokens: params.maxTokens,
          temperature: params.temperature,
          tools: ChatTools.cactusTools,
        ),
      );

      if (!result.success) throw Exception(result.response);

      final toolCalls = CactusToolLoop.extractToolCalls(result);

      if (toolCalls.isEmpty) {
        yield InferenceStreamUpdate.fromParsed(
          ThinkingParser.parse(result.response),
        );
        return;
      }

      if (!notifiedSearch) {
        notifiedSearch = true;
        yield const InferenceStreamUpdate(
          response: InferenceConstants.searchStatusMessage,
        );
      }

      cactusMessages = [
        ...cactusMessages,
        cactus.ChatMessage(
          role: 'assistant',
          content: CactusToolLoop.formatAssistantToolCalls(
            toolCalls,
            rawResponse: result.response,
          ),
        ),
      ];

      for (final call in toolCalls) {
        final toolResult = await _tools.executeCactus(call);
        cactusMessages = [
          ...cactusMessages,
          cactus.ChatMessage(
            role: 'tool',
            content: CactusToolLoop.formatToolResultMessage(call, toolResult),
          ),
        ];
      }
    }

    yield* _streamCactusMessages(
      lm: lm,
      cactusMessages: cactusMessages,
      params: params,
    );
  }
}

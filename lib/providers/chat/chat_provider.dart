import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/chat_engine_state.dart';
import '../../models/chat_message.dart';
import '../../models/chat_params.dart';
import '../../models/chat_state.dart';
import '../../models/inference_stream_update.dart';
import '../../models/llm_model.dart';
import '../../services/llm_inference_service.dart';
import '../../utils/stream_throttle.dart';
import '../conversations/conversations_provider.dart';
import 'chat_initialization_provider.dart';
import 'chat_params_provider.dart';

part 'chat_provider.g.dart';

@Riverpod(keepAlive: true)
class SelectedModel extends _$SelectedModel {
  @override
  LlmModel? build() => null;

  void setModel(LlmModel? model) {
    if (state?.slug == model?.slug) {
      state = model;
      _resetEngineIfNeeded(model);
      return;
    }

    state = model;
    if (model != null && !model.supportsWebSearch) {
      ref.read(chatParamsProvider.notifier).setWebSearchEnabled(false);
    }
    ref.read(chatEngineProvider.notifier).disposeEngine();
    ref.invalidate(chatInitializationProvider);
  }

  void _resetEngineIfNeeded(LlmModel? model) {
    if (model == null) return;
    final engine = ref.read(chatEngineProvider);
    if (engine == null || engine.modelSlug != model.slug) {
      ref.read(chatEngineProvider.notifier).disposeEngine();
      ref.invalidate(chatInitializationProvider);
    }
  }

  void markDownloaded() {
    final model = state;
    if (model == null || model.isDownloaded) return;
    state = model.copyWith(isDownloaded: true);
  }
}

@Riverpod(keepAlive: true)
class Chat extends _$Chat {
  final _inference = LlmInferenceService();
  int _generation = 0;
  Future<void>? _activeReplyFuture;

  @override
  ChatState build() => ChatState.initial();

  void loadMessages(List<AppChatMessage> messages) {
    state = ChatState(messages: messages, isLoading: false);
  }

  void clearMessages() {
    _generation++;
    _activeReplyFuture = null;
    state = ChatState.initial();
  }

  /// Stops an in-flight assistant reply when leaving chat mid-stream.
  Future<void> stopActiveGeneration() async {
    if (_activeReplyFuture == null && !state.isLoading) return;

    _generation++;
    _finalizeInterruptedGeneration();

    final pending = _activeReplyFuture;
    _activeReplyFuture = null;
    if (pending != null) {
      await pending.catchError((_) {});
    }
  }

  Future<void> addMessage(String text) async {
    await stopActiveGeneration();

    final model = ref.read(selectedModelProvider);
    final engine = ref.read(chatEngineProvider);
    if (model == null || engine == null) {
      throw Exception(
        'Modello non pronto. Attendi il completamento del download.',
      );
    }
    if (engine.modelSlug != model.slug) {
      ref.invalidate(chatInitializationProvider);
      throw Exception(
        'Modello in caricamento. Riprova tra qualche secondo.',
      );
    }

    final params = ref.read(chatParamsProvider);
    final conversations = ref.read(conversationsProvider.notifier);
    final conversationId = conversations.ensureActiveConversation();
    final generation = _generation;

    final userMessage = AppChatMessage(
      role: AppChatRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );
    conversations.syncMessages(conversationId, state.messages);

    final assistantTimestamp = DateTime.now();
    state = state.copyWith(
      messages: [
        ...state.messages,
        AppChatMessage(
          role: AppChatRole.assistant,
          content: '',
          timestamp: assistantTimestamp,
        ),
      ],
    );

    final history = state.messages.sublist(0, state.messages.length - 1);

    final reply = _streamAssistantReply(
      generation: generation,
      conversationId: conversationId,
      history: history,
      assistantTimestamp: assistantTimestamp,
      model: model,
      engine: engine,
      params: params,
      conversations: conversations,
    );
    _activeReplyFuture = reply;

    try {
      await reply;
    } catch (e) {
      if (generation == _generation) {
        _replaceLastWithError(e);
        conversations.syncMessages(conversationId, state.messages);
      }
      return;
    } finally {
      if (identical(_activeReplyFuture, reply)) {
        _activeReplyFuture = null;
      }
    }

    if (generation == _generation) {
      state = state.copyWith(isLoading: false);
      conversations.syncMessages(conversationId, state.messages);
    }
  }

  Future<void> _streamAssistantReply({
    required int generation,
    required String conversationId,
    required List<AppChatMessage> history,
    required DateTime assistantTimestamp,
    required LlmModel model,
    required ChatEngineState engine,
    required ChatParams params,
    required Conversations conversations,
  }) async {
    final uiThrottle = StreamThrottle();
    final syncThrottle = StreamThrottle(interval: const Duration(seconds: 1));
    InferenceStreamUpdate? pending;

    await for (final update in _inference.streamCompletion(
      model: model,
      cactusLm: engine.cactusLm,
      gemmaModel: engine.gemmaModel,
      messages: history,
      params: params,
    )) {
      if (generation != _generation) break;

      pending = update;
      if (!uiThrottle.shouldEmit()) continue;

      _applyUpdate(update, assistantTimestamp);

      if (syncThrottle.shouldEmit()) {
        conversations.syncMessages(conversationId, state.messages);
      }
    }

    if (generation != _generation) return;

    if (pending != null) {
      _applyUpdate(pending, assistantTimestamp);
    }

    _finalizeAssistant(assistantTimestamp);
    conversations.syncMessages(conversationId, state.messages);
  }

  void _finalizeInterruptedGeneration() {
    if (!state.isLoading) return;

    final messages = List<AppChatMessage>.from(state.messages);
    if (messages.isNotEmpty && messages.last.role == AppChatRole.assistant) {
      final last = messages.last;
      messages.last = AppChatMessage(
        role: last.role,
        content: last.content,
        timestamp: last.timestamp,
        reasoning: last.reasoning,
        isReasoningInProgress: false,
      );
    }

    state = state.copyWith(isLoading: false, messages: messages);

    final conversationId =
        ref.read(conversationsProvider.notifier).activeConversationId;
    if (conversationId != null) {
      ref
          .read(conversationsProvider.notifier)
          .syncMessages(conversationId, state.messages);
    }
  }

  void _applyUpdate(InferenceStreamUpdate update, DateTime timestamp) {
    final messages = List<AppChatMessage>.from(state.messages);
    messages.last = AppChatMessage(
      role: AppChatRole.assistant,
      content: update.response,
      timestamp: timestamp,
      reasoning: update.hasReasoning ? update.reasoning : null,
      isReasoningInProgress: update.isReasoningInProgress,
    );
    state = state.copyWith(messages: messages);
  }

  void _finalizeAssistant(DateTime timestamp) {
    final last = state.messages.last;
    final messages = List<AppChatMessage>.from(state.messages);
    messages.last = AppChatMessage(
      role: AppChatRole.assistant,
      content: last.content,
      timestamp: timestamp,
      reasoning: last.reasoning,
      isReasoningInProgress: false,
    );
    state = state.copyWith(messages: messages);
  }

  void _replaceLastWithError(Object error) {
    state = state.copyWith(
      messages: [
        ...state.messages.sublist(0, state.messages.length - 1),
        AppChatMessage(
          role: AppChatRole.assistant,
          content: 'Errore: $error',
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: false,
    );
  }
}

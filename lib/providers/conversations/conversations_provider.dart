import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../models/chat_message.dart';
import '../../models/conversation.dart';

part 'conversations_provider.g.dart';

@Riverpod(keepAlive: true)
class Conversations extends _$Conversations {
  static const _uuid = Uuid();

  @override
  List<Conversation> build() => [];

  String? _activeId;

  String? get activeConversationId => _activeId;

  Conversation? conversationById(String id) {
    try {
      return state.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void startNewConversation() {
    _activeId = null;
  }

  String ensureActiveConversation({String? title}) {
    if (_activeId != null) {
      final existing = conversationById(_activeId!);
      if (existing != null) return _activeId!;
    }

    final id = _uuid.v4();
    _activeId = id;
    final conversation = Conversation(
      id: id,
      title: title ?? 'Nuova chat',
      updatedAt: DateTime.now(),
      preview: '',
      messages: const [],
    );
    state = [conversation, ...state];
    return id;
  }

  void syncMessages(String conversationId, List<AppChatMessage> messages) {
    if (messages.isEmpty) return;

    final preview = messages.last.content;
    final title = _titleFromMessages(messages);

    state = [
      for (final c in state)
        if (c.id == conversationId)
          c.copyWith(
            title: title,
            preview: preview.length > 80 ? '${preview.substring(0, 80)}...' : preview,
            updatedAt: DateTime.now(),
            messages: List.unmodifiable(messages),
          )
        else
          c,
    ];
  }

  void loadConversation(String id) {
    _activeId = id;
  }

  void deleteConversation(String id) {
    state = state.where((c) => c.id != id).toList();
    if (_activeId == id) _activeId = null;
  }

  String _titleFromMessages(List<AppChatMessage> messages) {
    for (final message in messages) {
      if (message.role != AppChatRole.user) continue;
      final text = message.content.trim();
      if (text.isEmpty) continue;
      return text.length > 40 ? '${text.substring(0, 40)}...' : text;
    }
    return 'Nuova chat';
  }
}

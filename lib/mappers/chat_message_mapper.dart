import 'package:cactus/cactus.dart' as cactus;
import 'package:flutter_gemma/flutter_gemma.dart';

import '../models/chat_message.dart';

/// Maps app chat messages to backend-specific formats.
abstract final class ChatMessageMapper {
  static List<cactus.ChatMessage> toCactus(List<AppChatMessage> messages) {
    return messages
        .map(
          (msg) => cactus.ChatMessage(
            content: msg.content,
            role: msg.role == AppChatRole.user ? 'user' : 'assistant',
            timestamp: msg.timestamp.millisecondsSinceEpoch ~/ 1000,
          ),
        )
        .toList();
  }

  /// Replays conversation history into a Gemma chat session.
  ///
  /// The last user message is sent as the active query; earlier turns are
  /// context only.
  static Future<void> seedGemmaHistory(
    InferenceChat chat,
    List<AppChatMessage> messages,
  ) async {
    for (var i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final isLastUserTurn =
          i == messages.length - 1 && msg.role == AppChatRole.user;

      await chat.addQueryChunk(
        Message.text(
          text: msg.content,
          isUser: msg.role == AppChatRole.user,
        ),
      );

      if (isLastUserTurn) break;
    }
  }
}

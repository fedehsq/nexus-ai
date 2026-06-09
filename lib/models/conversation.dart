import 'chat_message.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.preview,
    required this.messages,
    this.iconName = 'chat_bubble',
  });

  final String id;
  final String title;
  final DateTime updatedAt;
  final String preview;
  final List<AppChatMessage> messages;
  final String iconName;

  Conversation copyWith({
    String? title,
    DateTime? updatedAt,
    String? preview,
    List<AppChatMessage>? messages,
    String? iconName,
  }) {
    return Conversation(
      id: id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      preview: preview ?? this.preview,
      messages: messages ?? this.messages,
      iconName: iconName ?? this.iconName,
    );
  }
}

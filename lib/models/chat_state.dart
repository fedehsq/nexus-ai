import 'chat_message.dart';

class ChatState {
  const ChatState({required this.messages, required this.isLoading});

  final List<AppChatMessage> messages;
  final bool isLoading;

  factory ChatState.initial() {
    return const ChatState(messages: [], isLoading: false);
  }

  ChatState copyWith({List<AppChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

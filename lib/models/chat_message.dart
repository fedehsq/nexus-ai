enum AppChatRole { user, assistant }

class AppChatMessage {
  const AppChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.reasoning,
    this.isReasoningInProgress = false,
  });

  final AppChatRole role;
  final String content;
  final DateTime timestamp;
  final String? reasoning;
  final bool isReasoningInProgress;
}

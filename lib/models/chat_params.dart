class ChatParams {
  const ChatParams({
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.webSearchEnabled = false,
  });

  final double temperature;
  final int maxTokens;
  final bool webSearchEnabled;

  ChatParams copyWith({
    double? temperature,
    int? maxTokens,
    bool? webSearchEnabled,
  }) {
    return ChatParams(
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      webSearchEnabled: webSearchEnabled ?? this.webSearchEnabled,
    );
  }
}

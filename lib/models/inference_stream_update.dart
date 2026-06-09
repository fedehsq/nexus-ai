import '../utils/thinking_parser.dart';

class InferenceStreamUpdate {
  const InferenceStreamUpdate({
    required this.response,
    this.reasoning,
    this.isReasoningInProgress = false,
  });

  final String response;
  final String? reasoning;
  final bool isReasoningInProgress;

  bool get hasReasoning => reasoning != null && reasoning!.trim().isNotEmpty;

  factory InferenceStreamUpdate.fromParsed(ThinkingParseResult parsed) {
    return InferenceStreamUpdate(
      response: parsed.response,
      reasoning: parsed.hasReasoning ? parsed.reasoning : null,
      isReasoningInProgress: parsed.isReasoningInProgress,
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_chat/utils/thinking_parser.dart';

void main() {
  group('ThinkingParser', () {
    test('parses complete redacted_thinking block', () {
      const raw = '''
<think>
Analizzo la domanda sul meteo.
</think>
Ecco la risposta finale.
''';
      final result = ThinkingParser.parse(raw);
      expect(result.reasoning, contains('Analizzo'));
      expect(result.response, contains('risposta finale'));
      expect(result.isReasoningInProgress, isFalse);
    });

    test('parses streaming thinking before closing tag', () {
      const raw = '<thinking>Sto pensando alla';
      final result = ThinkingParser.parse(raw);
      expect(result.reasoning, 'Sto pensando alla');
      expect(result.response, isEmpty);
      expect(result.isReasoningInProgress, isTrue);
    });
  });
}

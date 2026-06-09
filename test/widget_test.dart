import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_chat/main.dart';

void main() {
  testWidgets('App shows Nexus AI branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SmartChatApp()),
    );

    expect(find.text('Nexus AI'), findsWidgets);
  });
}

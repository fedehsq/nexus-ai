import 'package:flutter_test/flutter_test.dart';
import 'package:smart_chat/utils/external_url_resolver.dart';

void main() {
  group('ExternalUrlResolver.resolve', () {
    test('unwraps DuckDuckGo redirect with partial encoding', () {
      const redirect =
          'https://duckduckgo.com/l/?uddg=http%3A//www.technologyreview.com/topic/artificial-intelligence';

      expect(
        ExternalUrlResolver.resolve(redirect),
        'http://www.technologyreview.com/topic/artificial-intelligence',
      );
    });

    test('unwraps DuckDuckGo redirect with full encoding', () {
      const redirect =
          'https://duckduckgo.com/l/?uddg=https%3A%2F%2Fwww.quotidiano.net%2FCtagAI&rut=abc';

      expect(
        ExternalUrlResolver.resolve(redirect),
        'https://www.quotidiano.net/CtagAI',
      );
    });

    test('adds https scheme to protocol-relative URLs', () {
      expect(
        ExternalUrlResolver.resolve('//example.com/path'),
        'https://example.com/path',
      );
    });

    test('returns direct URLs unchanged', () {
      const direct = 'https://example.com/article';
      expect(ExternalUrlResolver.resolve(direct), direct);
    });
  });

  group('ExternalUrlResolver.isValidHttpUrl', () {
    test('accepts http and https URLs', () {
      expect(
        ExternalUrlResolver.isValidHttpUrl('https://example.com'),
        isTrue,
      );
      expect(
        ExternalUrlResolver.isValidHttpUrl('http://example.com'),
        isTrue,
      );
    });

    test('rejects invalid URLs', () {
      expect(
        ExternalUrlResolver.isValidHttpUrl('not a url'),
        isFalse,
      );
      expect(
        ExternalUrlResolver.isValidHttpUrl('ftp://example.com'),
        isFalse,
      );
    });
  });
}

/// Resolves redirect/tracking URLs to the final destination.
abstract final class ExternalUrlResolver {
  static String resolve(String rawUrl) {
    var url = rawUrl.trim();
    if (url.isEmpty) return url;

    if (url.startsWith('//')) {
      url = 'https:$url';
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    if (_isDuckDuckGoRedirect(uri)) {
      final target = uri.queryParameters['uddg'];
      if (target != null && target.isNotEmpty) {
        final decoded = Uri.decodeComponent(target);
        if (decoded != url) {
          return resolve(decoded);
        }
      }
    }

    return url;
  }

  static bool isValidHttpUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static bool _isDuckDuckGoRedirect(Uri uri) {
    return uri.host.endsWith('duckduckgo.com') && uri.path.startsWith('/l');
  }
}

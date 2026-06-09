/// Limits callback frequency during token streaming to keep the UI responsive.
class StreamThrottle {
  StreamThrottle({this.interval = const Duration(milliseconds: 120)});

  final Duration interval;

  DateTime? _lastEmit;

  bool shouldEmit() {
    final now = DateTime.now();
    if (_lastEmit == null || now.difference(_lastEmit!) >= interval) {
      _lastEmit = now;
      return true;
    }
    return false;
  }

  void reset() {
    _lastEmit = null;
  }
}

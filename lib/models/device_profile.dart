/// Snapshot of device hardware relevant to on-device LLM inference.
class DeviceProfile {
  const DeviceProfile({
    this.ramMb,
    this.isAndroid = false,
  });

  /// Total physical RAM in megabytes, when available.
  final int? ramMb;
  final bool isAndroid;

  /// Devices below 6 GB struggle with Gemma 4 (model + GPU compile buffers).
  static const lowRamThresholdMb = 6144;

  bool get isLowRam =>
      ramMb != null && ramMb! < DeviceProfile.lowRamThresholdMb;

  bool canRunHeavyModels({required bool modelRequiresHighEndDevice}) {
    if (!modelRequiresHighEndDevice) return true;
    if (ramMb == null) return true;
    return !isLowRam;
  }

  String get ramLabel {
    if (ramMb == null) return 'RAM sconosciuta';
    final gb = ramMb! / 1024;
    return gb >= 1 ? '${gb.toStringAsFixed(1)} GB' : '$ramMb MB';
  }
}

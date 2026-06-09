import 'package:flutter_gemma/flutter_gemma.dart';

import '../models/device_profile.dart';

/// Chooses the Gemma [.litertlm] accelerator preference.
///
/// flutter_gemma falls back automatically (GPU→CPU or NPU→GPU→CPU).
/// On low-RAM Android we force CPU: OpenCL GPU init for Gemma 4 allocates
/// large compile buffers and often triggers an OOM kill (e.g. Galaxy A14 4 GB).
abstract final class GemmaBackendSelector {
  static PreferredBackend preferredFor(DeviceProfile profile) {
    if (profile.isAndroid && profile.isLowRam) {
      return PreferredBackend.cpu;
    }
    return PreferredBackend.gpu;
  }

  static String label(PreferredBackend? backend) {
    return switch (backend) {
      PreferredBackend.npu => 'NPU',
      PreferredBackend.gpu => 'GPU',
      PreferredBackend.cpu => 'CPU',
      null => 'Sconosciuto',
    };
  }

  static String? backendReason(DeviceProfile profile, PreferredBackend? active) {
    if (profile.isLowRam && active == PreferredBackend.cpu) {
      return 'Modalità CPU per ${profile.ramLabel} di RAM '
          '(GPU rischia out-of-memory su modelli grandi).';
    }
    return null;
  }
}

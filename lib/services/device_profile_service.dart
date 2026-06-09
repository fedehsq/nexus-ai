import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';

import '../models/device_profile.dart';

/// Reads hardware capabilities used to pick inference backends and warn users.
abstract final class DeviceProfileService {
  static final _plugin = DeviceInfoPlugin();

  static Future<DeviceProfile> load() async {
    if (Platform.isAndroid) {
      final info = await _plugin.androidInfo;
      return DeviceProfile(
        ramMb: info.physicalRamSize,
        isAndroid: true,
      );
    }

    if (Platform.isIOS) {
      final info = await _plugin.iosInfo;
      return DeviceProfile(ramMb: info.physicalRamSize);
    }

    return const DeviceProfile();
  }
}

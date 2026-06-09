import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/device_profile.dart';
import '../../services/device_profile_service.dart';

part 'device_profile_provider.g.dart';

@Riverpod(keepAlive: true)
Future<DeviceProfile> deviceProfile(Ref ref) {
  return DeviceProfileService.load();
}

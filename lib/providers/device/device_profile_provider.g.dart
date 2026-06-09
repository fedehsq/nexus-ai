// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceProfile)
final deviceProfileProvider = DeviceProfileProvider._();

final class DeviceProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeviceProfile>,
          DeviceProfile,
          FutureOr<DeviceProfile>
        >
    with $FutureModifier<DeviceProfile>, $FutureProvider<DeviceProfile> {
  DeviceProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceProfileHash();

  @$internal
  @override
  $FutureProviderElement<DeviceProfile> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeviceProfile> create(Ref ref) {
    return deviceProfile(ref);
  }
}

String _$deviceProfileHash() => r'3a2b210cfbe5e730007590e9848a746d4e3b0d9c';

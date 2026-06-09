// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Models)
final modelsProvider = ModelsProvider._();

final class ModelsProvider extends $AsyncNotifierProvider<Models, ModelsState> {
  ModelsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modelsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modelsHash();

  @$internal
  @override
  Models create() => Models();
}

String _$modelsHash() => r'fcdaa842dbe76aa02f6ac821e849c1caebd1aba9';

abstract class _$Models extends $AsyncNotifier<ModelsState> {
  FutureOr<ModelsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ModelsState>, ModelsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ModelsState>, ModelsState>,
              AsyncValue<ModelsState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

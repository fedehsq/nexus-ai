// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_initialization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatEngine)
final chatEngineProvider = ChatEngineProvider._();

final class ChatEngineProvider
    extends $NotifierProvider<ChatEngine, ChatEngineState?> {
  ChatEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatEngineHash();

  @$internal
  @override
  ChatEngine create() => ChatEngine();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatEngineState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatEngineState?>(value),
    );
  }
}

String _$chatEngineHash() => r'836ec8be586537d2f26d9f4c7c6837c6ecf575d7';

abstract class _$ChatEngine extends $Notifier<ChatEngineState?> {
  ChatEngineState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatEngineState?, ChatEngineState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatEngineState?, ChatEngineState?>,
              ChatEngineState?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(chatInitialization)
final chatInitializationProvider = ChatInitializationProvider._();

final class ChatInitializationProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  ChatInitializationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatInitializationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatInitializationHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return chatInitialization(ref);
  }
}

String _$chatInitializationHash() =>
    r'6e6907593264f9003d3d766182d430f044bdecc7';

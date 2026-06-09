// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_params_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatParamsNotifier)
final chatParamsProvider = ChatParamsNotifierProvider._();

final class ChatParamsNotifierProvider
    extends $NotifierProvider<ChatParamsNotifier, ChatParams> {
  ChatParamsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatParamsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatParamsNotifierHash();

  @$internal
  @override
  ChatParamsNotifier create() => ChatParamsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatParams value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatParams>(value),
    );
  }
}

String _$chatParamsNotifierHash() =>
    r'770db639aee781fc71a280bcfc42352b5d685c47';

abstract class _$ChatParamsNotifier extends $Notifier<ChatParams> {
  ChatParams build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatParams, ChatParams>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatParams, ChatParams>,
              ChatParams,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

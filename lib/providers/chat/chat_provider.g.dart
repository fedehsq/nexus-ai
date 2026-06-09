// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedModel)
final selectedModelProvider = SelectedModelProvider._();

final class SelectedModelProvider
    extends $NotifierProvider<SelectedModel, LlmModel?> {
  SelectedModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedModelHash();

  @$internal
  @override
  SelectedModel create() => SelectedModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LlmModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LlmModel?>(value),
    );
  }
}

String _$selectedModelHash() => r'dd7fd27bb91fd3718a727d3c0fe8e48c09dd8374';

abstract class _$SelectedModel extends $Notifier<LlmModel?> {
  LlmModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LlmModel?, LlmModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LlmModel?, LlmModel?>,
              LlmModel?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Chat)
final chatProvider = ChatProvider._();

final class ChatProvider extends $NotifierProvider<Chat, ChatState> {
  ChatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatHash();

  @$internal
  @override
  Chat create() => Chat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatState>(value),
    );
  }
}

String _$chatHash() => r'88a38d99952f4e9e6bf81f26181d0c057af373d5';

abstract class _$Chat extends $Notifier<ChatState> {
  ChatState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatState, ChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatState, ChatState>,
              ChatState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

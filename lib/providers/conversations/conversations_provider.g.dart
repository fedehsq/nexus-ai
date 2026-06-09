// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Conversations)
final conversationsProvider = ConversationsProvider._();

final class ConversationsProvider
    extends $NotifierProvider<Conversations, List<Conversation>> {
  ConversationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationsHash();

  @$internal
  @override
  Conversations create() => Conversations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Conversation> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Conversation>>(value),
    );
  }
}

String _$conversationsHash() => r'033db49d6a354b084e75f6df7adee437faf60d17';

abstract class _$Conversations extends $Notifier<List<Conversation>> {
  List<Conversation> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Conversation>, List<Conversation>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Conversation>, List<Conversation>>,
              List<Conversation>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

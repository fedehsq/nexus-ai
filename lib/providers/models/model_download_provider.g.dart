// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_download_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ModelDownload)
final modelDownloadProvider = ModelDownloadProvider._();

final class ModelDownloadProvider
    extends $NotifierProvider<ModelDownload, ModelDownloadState> {
  ModelDownloadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modelDownloadProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modelDownloadHash();

  @$internal
  @override
  ModelDownload create() => ModelDownload();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModelDownloadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModelDownloadState>(value),
    );
  }
}

String _$modelDownloadHash() => r'13ae6579783e931a91985cd5eb7cfbad97b92a21';

abstract class _$ModelDownload extends $Notifier<ModelDownloadState> {
  ModelDownloadState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ModelDownloadState, ModelDownloadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ModelDownloadState, ModelDownloadState>,
              ModelDownloadState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

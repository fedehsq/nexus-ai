import 'llm_model.dart';

class ModelsState {
  const ModelsState({
    required this.models,
    required this.isDownloading,
    required this.downloadProgress,
    required this.downloadStatus,
    this.downloadingModelSlug,
  });

  final List<LlmModel> models;
  final bool isDownloading;
  final double downloadProgress;
  final String downloadStatus;
  final String? downloadingModelSlug;

  factory ModelsState.initial() {
    return const ModelsState(
      models: [],
      isDownloading: false,
      downloadProgress: 0,
      downloadStatus: '',
    );
  }

  ModelsState copyWith({
    List<LlmModel>? models,
    bool? isDownloading,
    double? downloadProgress,
    String? downloadStatus,
    String? downloadingModelSlug,
    bool clearDownloadingModelSlug = false,
  }) {
    return ModelsState(
      models: models ?? this.models,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadingModelSlug: clearDownloadingModelSlug
          ? null
          : (downloadingModelSlug ?? this.downloadingModelSlug),
    );
  }
}

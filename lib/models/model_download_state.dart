enum ModelDownloadPhase {
  idle,
  downloading,
  initializing,
  completed,
  cancelled,
  error,
}

class ModelDownloadState {
  const ModelDownloadState({
    this.phase = ModelDownloadPhase.idle,
    this.progress,
    this.status = '',
    this.modelSlug,
  });

  final ModelDownloadPhase phase;
  final double? progress;
  final String status;
  final String? modelSlug;

  bool get isActive =>
      phase == ModelDownloadPhase.downloading ||
      phase == ModelDownloadPhase.initializing;

  bool get hasFailed => phase == ModelDownloadPhase.error;

  ModelDownloadState copyWith({
    ModelDownloadPhase? phase,
    double? progress,
    bool clearProgress = false,
    String? status,
    String? modelSlug,
  }) {
    return ModelDownloadState(
      phase: phase ?? this.phase,
      progress: clearProgress ? null : (progress ?? this.progress),
      status: status ?? this.status,
      modelSlug: modelSlug ?? this.modelSlug,
    );
  }
}

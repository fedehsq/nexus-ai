import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../chat/chat_initialization_provider.dart';
import 'model_download_provider.dart';
import 'models_provider.dart';

Future<void> cancelActiveModelDownload(WidgetRef ref) async {
  await ref.read(modelDownloadProvider.notifier).cancelDownload();
  ref.read(modelDownloadProvider.notifier).reset();
  ref.read(modelsProvider.notifier).clearDownloadingState();
  await ref.read(chatEngineProvider.notifier).disposeEngine();
}

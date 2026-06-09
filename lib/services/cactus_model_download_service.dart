import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:cactus/cactus.dart' as cactus;
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/core/model_management/cancel_token.dart';
import 'package:path_provider/path_provider.dart';

/// Cancellable Cactus model download (the stock [cactus.CactusLM.downloadModel]
/// does not expose cancellation).
abstract final class CactusModelDownloadService {
  static HttpClient? _activeClient;

  static void abort() {
    _activeClient?.close(force: true);
    _activeClient = null;
  }

  static Future<void> downloadIfNeeded({
    required cactus.CactusLM lm,
    required String modelSlug,
    required cactus.CactusProgressCallback onProgress,
    required CancelToken cancelToken,
  }) async {
    cancelToken.throwIfCancelled();

    if (await _modelExists(modelSlug)) {
      return;
    }

    final models = await lm.getModels();
    cactus.CactusModel? model;
    for (final candidate in models) {
      if (candidate.slug == modelSlug) {
        model = candidate;
        break;
      }
    }
    if (model == null) {
      throw Exception('Modello Cactus non trovato: $modelSlug');
    }

    final filename =
        model.downloadUrl.split('?').first.split('/').last;
    final success = await _downloadAndExtract(
      url: model.downloadUrl,
      filename: filename,
      folder: model.slug,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );

    if (!success) {
      cancelToken.throwIfCancelled();
      throw Exception('Download del modello $modelSlug non riuscito');
    }
  }

  static Future<bool> isModelCached(String modelSlug) => _modelExists(modelSlug);

  static Future<bool> _modelExists(String folderName) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final modelFolder = Directory('${appDocDir.path}/models/$folderName');
    if (!await modelFolder.exists()) return false;
    final files = await modelFolder.list().toList();
    return files.isNotEmpty;
  }

  static Future<bool> _downloadAndExtract({
    required String url,
    required String filename,
    required String folder,
    required cactus.CactusProgressCallback onProgress,
    required CancelToken cancelToken,
  }) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${appDocDir.path}/models');
    final modelFolderPath = '${modelsDir.path}/$folder';
    final modelFolder = Directory(modelFolderPath);

    if (await modelFolder.exists()) {
      final files = await modelFolder.list().toList();
      if (files.isNotEmpty) return true;
    }

    await modelsDir.create(recursive: true);
    final zipFilePath = '${modelsDir.path}/$filename';
    final client = HttpClient();
    _activeClient = client;

    try {
      cancelToken.throwIfCancelled();
      onProgress(null, 'Avvio download...', false);

      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        onProgress(
          null,
          'Download fallito: ${response.statusCode}',
          true,
        );
        throw Exception('Download fallito: ${response.statusCode}');
      }

      final contentLength = response.contentLength;
      final zipFile = File(zipFilePath);
      final sink = zipFile.openWrite();
      var totalBytes = 0;

      await for (final chunk in response) {
        cancelToken.throwIfCancelled();
        sink.add(chunk);
        totalBytes += chunk.length;
        if (contentLength > 0) {
          onProgress(
            totalBytes / contentLength,
            'Scaricati ${totalBytes ~/ (1024 * 1024)} MB...',
            false,
          );
        } else if (totalBytes % (10 * 1024 * 1024) == 0) {
          onProgress(
            null,
            'Scaricati ${totalBytes ~/ (1024 * 1024)} MB...',
            false,
          );
        }
      }

      await sink.close();
      cancelToken.throwIfCancelled();
      onProgress(1.0, 'Estrazione in corso...', false);

      if (filename.toLowerCase().endsWith('.zip')) {
        await _extractZip(
          zipFilePath: zipFilePath,
          extractToPath: modelFolderPath,
          onProgress: onProgress,
          cancelToken: cancelToken,
        );
        await zipFile.delete();
      } else {
        await modelFolder.create(recursive: true);
        await zipFile.rename('$modelFolderPath/$filename');
      }

      onProgress(1.0, 'Download completato', false);
      return true;
    } on DownloadCancelledException {
      await _cleanupPartialDownload(zipFilePath, modelFolder);
      rethrow;
    } catch (e) {
      onProgress(null, 'Download fallito: $e', true);
      debugPrint('Cactus download failed: $e');
      await _cleanupPartialDownload(zipFilePath, modelFolder);
      return false;
    } finally {
      client.close();
      if (identical(_activeClient, client)) {
        _activeClient = null;
      }
    }
  }

  static Future<void> _extractZip({
    required String zipFilePath,
    required String extractToPath,
    required cactus.CactusProgressCallback onProgress,
    required CancelToken cancelToken,
  }) async {
    cancelToken.throwIfCancelled();
    final modelFolder = Directory(extractToPath);
    await modelFolder.create(recursive: true);
    onProgress(null, 'Estrazione file...', false);

    final inputStream = InputFileStream(zipFilePath);
    try {
      final archive = ZipDecoder().decodeStream(inputStream);
      final symbolicLinks = <ArchiveFile>[];
      String? rootFolderName;

      for (final file in archive) {
        if (file.isFile || file.isDirectory) {
          final pathParts = file.name.split('/');
          if (pathParts.isNotEmpty) {
            rootFolderName ??= pathParts.first;
            break;
          }
        }
      }

      for (final file in archive) {
        cancelToken.throwIfCancelled();
        if (file.isSymbolicLink) {
          symbolicLinks.add(file);
          continue;
        }

        var relativePath = file.name;
        if (rootFolderName != null &&
            relativePath.startsWith('$rootFolderName/')) {
          relativePath = relativePath.substring(rootFolderName.length + 1);
        }
        if (relativePath.isEmpty) continue;

        if (file.isFile) {
          final extractedFilePath = '$extractToPath/$relativePath';
          await File(extractedFilePath).parent.create(recursive: true);
          final outputStream = OutputFileStream(extractedFilePath);
          file.writeContent(outputStream);
          outputStream.closeSync();
        } else {
          await Directory('$extractToPath/$relativePath')
              .create(recursive: true);
        }
      }

      for (final file in symbolicLinks) {
        cancelToken.throwIfCancelled();
        var relativePath = file.name;
        if (rootFolderName != null &&
            relativePath.startsWith('$rootFolderName/')) {
          relativePath = relativePath.substring(rootFolderName.length + 1);
        }
        if (relativePath.isEmpty) continue;
        await Link('$extractToPath/$relativePath')
            .create(file.symbolicLink!, recursive: true);
      }
    } finally {
      inputStream.close();
    }
  }

  static Future<void> _cleanupPartialDownload(
    String zipFilePath,
    Directory modelFolder,
  ) async {
    try {
      final zipFile = File(zipFilePath);
      if (await zipFile.exists()) {
        await zipFile.delete();
      }
      if (await modelFolder.exists()) {
        final files = await modelFolder.list().toList();
        if (files.length < 5) {
          await modelFolder.delete(recursive: true);
        }
      }
    } catch (e) {
      debugPrint('Cactus download cleanup failed: $e');
    }
  }
}

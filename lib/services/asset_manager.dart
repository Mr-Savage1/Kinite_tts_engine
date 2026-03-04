import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AssetManager {
  static const Map<String, List<String>> _engineFiles = {
    'kokoro': ['model.ort', 'voices.bin', 'tokens.txt'],
    'piper': ['model.ort', 'tokens.txt'],
    'kitten': ['model.ort', 'voices.bin', 'tokens.txt'],
    'coqui': ['model.ort', 'tokens.txt'],
  };

  static Future<void> syncSelective(String engineName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final folder = engineName.toLowerCase();
    final basePath = appDir.path;

    // 1. Sync Espeak-NG Data (Atomic)
    final espeakDir = Directory('$basePath/assets/rex_core/espeak-ng-data');
    if (!await espeakDir.exists()) {
      final manifestStr = await rootBundle.loadString('assets/rex_core/espeak-ng-data/manifest.txt');
      final files = manifestStr.split('\n').where((f) => f.trim().isNotEmpty).toList();
      
      for (var f in files) {
        await _copy(
          'assets/rex_core/espeak-ng-data/${f.trim()}',
          '$basePath/assets/rex_core/espeak-ng-data/${f.trim()}'
        );
      }
    }

    // 2. Sync Selected Engine (Atomic)
    if (_engineFiles.containsKey(folder)) {
      final tasks = _engineFiles[folder]!.map((file) => _copy(
          'assets/rex_engines/$folder/$file',
          '$basePath/assets/rex_engines/$folder/$file'
      ));
      await Future.wait(tasks);
    }
  }

  static Future<void> _copy(String asset, String local) async {
    final file = File(local);
    if (await file.exists()) return;

    final tmpFile = File('$local.tmp');
    await tmpFile.parent.create(recursive: true);

    try {
      final ByteData data = await rootBundle.load(asset);
      // Use buffer directly for memory efficiency
      await tmpFile.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true
      );
      await tmpFile.rename(local); // Atomic swap
    } catch (e) {
      if (await tmpFile.exists()) await tmpFile.delete();
      rethrow;
    }
  }
}

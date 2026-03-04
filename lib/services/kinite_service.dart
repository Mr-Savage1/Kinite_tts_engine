import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

class _SynthTask {
  final String text;
  final int sid;
  final double speed;
  _SynthTask(this.text, this.sid, {this.speed = 1.0});
}

class KiniteService {
  SendPort? _sendPort;
  Isolate? _isolate;

  final _audioController = StreamController<dynamic>.broadcast();
  final _logController = StreamController<String>.broadcast();

  Stream<dynamic> get audioStream => _audioController.stream;
  Stream<String> get logs => _logController.stream;

  Future<void> initEngine(String type) async {
    _logController.add("--- INITIALIZING ENGINE: $type ---");

    if (_isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
      _sendPort = null;
    }

    final receivePort = ReceivePort();
    final appDir = (await getApplicationDocumentsDirectory()).path;

    _isolate = await Isolate.spawn(_engineWorker, [receivePort.sendPort, type, appDir]);

    receivePort.listen((msg) {
      if (msg is SendPort) {
        _sendPort = msg;
        _logController.add("STATUS: Engine Isolate Ready ✅");
      } else if (msg is String) {
        if (msg.startsWith("[LOG]")) {
          _logController.add(msg.replaceFirst("[LOG]", "SYSTEM: "));
        } else if (msg.startsWith("[ERR]")) {
          _logController.add("🚨 ERROR: ${msg.replaceFirst("[ERR]", "")}");
        } else if (msg == "[DONE]") {
          _audioController.add("[DONE]");
        }
      } else if (msg is TransferableTypedData) {
        _audioController.add(msg.materialize().asUint8List());
      }
    });
  }

  void requestSynthesis(String text, int sid, {double speed = 1.0}) {
    if (_sendPort == null) return;
    _sendPort!.send(_SynthTask(text, sid, speed: speed));
  }

  static void _engineWorker(List<dynamic> args) async {
    final SendPort mainSendPort = args[0];
    final String type = args[1];
    final String appDir = args[2];
    final workerRecPort = ReceivePort();
    mainSendPort.send(workerRecPort.sendPort);

    try {
      sherpa.initBindings();

      final folder = type.toLowerCase();
      final modelPath = '$appDir/assets/rex_engines/$folder/model.ort';
      final tokensPath = '$appDir/assets/rex_engines/$folder/tokens.txt';
      final voicesPath = '$appDir/assets/rex_engines/$folder/voices.bin';
      final dataDirPath = '$appDir/assets/rex_core/espeak-ng-data';

      final config = sherpa.OfflineTtsConfig(
        model: sherpa.OfflineTtsModelConfig(
          kokoro: type == "Kokoro" ? sherpa.OfflineTtsKokoroModelConfig(
            model: modelPath, voices: voicesPath, tokens: tokensPath, dataDir: dataDirPath,
          ) : const sherpa.OfflineTtsKokoroModelConfig(),
          kitten: type == "Kitten" ? sherpa.OfflineTtsKittenModelConfig(
            model: modelPath, voices: voicesPath, tokens: tokensPath, dataDir: dataDirPath,
          ) : const sherpa.OfflineTtsKittenModelConfig(),
          vits: (type != "Kokoro" && type != "Kitten") ? sherpa.OfflineTtsVitsModelConfig(
            model: modelPath, tokens: tokensPath, dataDir: dataDirPath,
            noiseScale: 0.667, noiseScaleW: 0.8, lengthScale: 1.0,
          ) : const sherpa.OfflineTtsVitsModelConfig(),
          numThreads: 4, 
          debug: false,
        ),
      );

      final tts = sherpa.OfflineTts(config);
      mainSendPort.send("[LOG] Streaming Pipeline Ready.");

      await for (final msg in workerRecPort) {
        if (msg is _SynthTask) {
          String safeText = msg.text
              .replaceAll(RegExp(r'(?<=[.!?])(?=[^\s])'), ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();

          final List<String> segments = safeText
              .split(RegExp(r'(?<!\b(?:Mr|Dr|Ms|Mrs|St|Ave)\.)(?<=[.!?])\s+'))
              .where((s) => s.isNotEmpty)
              .toList();

          if (segments.isEmpty && safeText.isNotEmpty) segments.add(safeText);

          for (int i = 0; i < segments.length; i++) {
            final stopwatch = Stopwatch()..start();
            String sentence = (i == 0 ? ", " : "") + segments[i].trim();
            final res = tts.generate(text: sentence, sid: msg.sid, speed: msg.speed);

            if (res.samples.isNotEmpty) {
              final samplesWithBreath = Float32List.fromList([
                ...res.samples,
                ...List<double>.filled((res.sampleRate * 0.2).toInt(), 0.0)
              ]);

              final wavBytes = _samplesToWav(samplesWithBreath, res.sampleRate);
              mainSendPort.send(TransferableTypedData.fromList([wavBytes]));
              mainSendPort.send("[LOG] Chunk ${i + 1}/${segments.length} generated in ${stopwatch.elapsedMilliseconds}ms");
            }
          }
          mainSendPort.send("[DONE]");
        }
      }
    } catch (e) {
      mainSendPort.send("[ERR] Isolate Error: $e");
    }
  }
}

Uint8List _samplesToWav(Float32List samples, int sampleRate) {
  final int numSamples = samples.length;
  final Int16List pcm = Int16List(numSamples);
  for (int i = 0; i < numSamples; i++) {
    pcm[i] = (samples[i].clamp(-1.0, 1.0) * 32767).round();
  }
  final h = BytesBuilder(copy: false);
  h.add('RIFF'.codeUnits);
  h.add(Uint8List(4)..buffer.asByteData().setInt32(0, 36 + numSamples * 2, Endian.little));
  h.add('WAVEfmt '.codeUnits);
  h.add(Uint8List(4)..buffer.asByteData().setInt32(0, 16, Endian.little));
  h.add(Uint8List(2)..buffer.asByteData().setInt16(0, 1, Endian.little));
  h.add(Uint8List(2)..buffer.asByteData().setInt16(0, 1, Endian.little));
  h.add(Uint8List(4)..buffer.asByteData().setInt32(0, sampleRate, Endian.little));
  h.add(Uint8List(4)..buffer.asByteData().setInt32(0, sampleRate * 2, Endian.little));
  h.add(Uint8List(2)..buffer.asByteData().setInt16(0, 2, Endian.little));
  h.add(Uint8List(2)..buffer.asByteData().setInt16(0, 16, Endian.little));
  h.add('data'.codeUnits);
  h.add(Uint8List(4)..buffer.asByteData().setInt32(0, numSamples * 2, Endian.little));
  return Uint8List.fromList(h.toBytes() + pcm.buffer.asUint8List());
}

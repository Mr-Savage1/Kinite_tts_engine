import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'dart:typed_data';

class KiniteHardware {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isWarmed = false;

  static Future<void> optimizeForAndroid() async {
    if (Platform.isAndroid) {
      await _player.setAudioContext(const AudioContext(
        android: AudioContextAndroid(
          usageType: AndroidUsageType.media,
          contentType: AndroidContentType.speech,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ));
    }
  }

  /// Pre-warms the audio engine to eliminate the "first play" delay.
  static Future<void> prewarm() async {
    if (_isWarmed) return;
    try {
      // A 10ms silent WAV header to initialize the Android AudioTrack
      final silentWav = Uint8List.fromList([
        0x52, 0x49, 0x46, 0x46, 0x26, 0x00, 0x00, 0x00, 0x57, 0x41, 0x56, 0x45, 
        0x66, 0x6d, 0x74, 0x20, 0x10, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 
        0x80, 0xbb, 0x00, 0x00, 0x00, 0x77, 0x01, 0x00, 0x02, 0x00, 0x10, 0x00, 
        0x64, 0x61, 0x74, 0x61, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00
      ]);
      await _player.setSource(BytesSource(silentWav));
      _isWarmed = true;
    } catch (_) {}
  }

  static Future<void> playBytes(Uint8List bytes) async {
    try {
      // Using BytesSource avoids slow Disk I/O
      await _player.play(BytesSource(bytes));
      await _player.onPlayerComplete.first;
    } catch (e) {
      print("Hardware Play Error: $e");
    }
  }

  static void stop() => _player.stop();
}

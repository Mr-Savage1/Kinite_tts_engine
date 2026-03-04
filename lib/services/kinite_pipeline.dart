import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'kinite_service.dart';
import 'kinite_hardware.dart';

class KinitePipeline {
  final KiniteService _service;
  StreamSubscription? _sub;
  
  // Audio Queue Management
  final Queue<Uint8List> _queue = Queue<Uint8List>();
  bool _isPlaying = false;
  bool _isSynthesisDone = false;

  KinitePipeline(this._service);

  void start(String text, int sid, Function(String) onLat) {
    final watch = Stopwatch()..start();
    _reset();

    _sub = _service.audioStream.listen((msg) async {
      if (msg is Uint8List) {
        if (_queue.isEmpty && !_isPlaying) {
          onLat("${watch.elapsedMilliseconds}ms");
        }
        _queue.add(msg);
        _processQueue();
      } else if (msg == "[DONE]") {
        _isSynthesisDone = true;
      }
    });

    if (text.trim().isNotEmpty) {
      KiniteHardware.prewarm();
      _service.requestSynthesis(text, sid);
    }
  }

  Future<void> _processQueue() async {
    if (_isPlaying || _queue.isEmpty) return;

    _isPlaying = true;
    while (_queue.isNotEmpty) {
      final bytes = _queue.removeFirst();
      await KiniteHardware.playBytes(bytes);
    }
    _isPlaying = false;

    // Optional: Reset if synthesis is fully done and queue is empty
    if (_isSynthesisDone && _queue.isEmpty) {
      // Logic for full completion if needed
    }
  }

  void _reset() {
    _sub?.cancel();
    _queue.clear();
    _isPlaying = false;
    _isSynthesisDone = false;
    KiniteHardware.stop();
  }

  void stop() {
    _reset();
  }
}

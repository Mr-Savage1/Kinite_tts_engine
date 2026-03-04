import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/kinite_service.dart';
import '../services/kinite_pipeline.dart';
import '../services/kinite_hardware.dart';
import '../services/asset_manager.dart';
import '../services/speaker_data.dart';

// rest of the file unchanged (same as previously provided)

class TtsProvider extends ChangeNotifier {
  // Services
  final KiniteService _service = KiniteService();
  late KinitePipeline _pipeline;
  StreamSubscription? _logSub;

  // State
  bool _isReady = false;
  bool _isSpeaking = false;
  String _engine = 'Kokoro';
  String _voice = 'af_heart';
  int _sid = 0;
  double _speed = 1.0;
  ThemeMode _themeMode = ThemeMode.system;
  final List<String> _consoleLogs = [];

  // Getters
  bool get isReady => _isReady;
  bool get isSpeaking => _isSpeaking;
  String get engine => _engine;
  String get voice => _voice;
  int get sid => _sid;
  double get speed => _speed;
  ThemeMode get themeMode => _themeMode;
  List<String> get consoleLogs => List.unmodifiable(_consoleLogs);

  TtsProvider() {
    _init();
  }

  Future<void> _init() async {
    _pipeline = KinitePipeline(_service);
    _logSub = _service.logs.listen((log) {
      _addLog(log);
    });
    await KiniteHardware.optimizeForAndroid();
    await _loadSavedSettings();
    await loadEngine(_engine);
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _engine = prefs.getString('engine') ?? 'Kokoro';
    _voice = prefs.getString('voice') ?? SpeakerData.getVoices(_engine).first;
    _speed = prefs.getDouble('speed') ?? 1.0;
    final themeIndex = prefs.getInt('themeMode') ?? 2;
    _themeMode = ThemeMode.values[themeIndex];
    _updateSidFromVoice();
    notifyListeners();
  }

  void _updateSidFromVoice() {
    _sid = SpeakerData.getSid(_engine, _voice);
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('engine', _engine);
    await prefs.setString('voice', _voice);
    await prefs.setDouble('speed', _speed);
    await prefs.setInt('themeMode', _themeMode.index);
  }

  Future<void> loadEngine(String name) async {
    if (name == _engine && _isReady) return;
    _addLog('SYSTEM: Loading engine $name...');
    _isReady = false;
    notifyListeners();

    await AssetManager.syncSelective(name);
    await _service.initEngine(name);

    _engine = name;
    _voice = SpeakerData.getVoices(_engine).first;
    _updateSidFromVoice();
    _isReady = true;
    _addLog('SYSTEM: Engine $name ready ✅');
    await saveSettings();
    notifyListeners();
  }

  void selectVoice(String voiceName) {
    _voice = voiceName;
    _updateSidFromVoice();
    _addLog('VOICE: Changed to $_voice (SID: $_sid)');
    saveSettings();
    notifyListeners();
  }

  void setSpeed(double value) {
    _speed = value;
    saveSettings();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    saveSettings();
    notifyListeners();
  }

  void speak(String text) {
    if (text.isEmpty || !_isReady || _isSpeaking) return;
    _isSpeaking = true;
    notifyListeners();

    _pipeline.start(text, _sid, (latency) {
      _addLog('LATENCY: $latency');
      _isSpeaking = false;
      notifyListeners();
    });
  }

  void stop() {
    _pipeline.stop();
    _isSpeaking = false;
    _addLog('SYSTEM: Synthesis stopped');
    notifyListeners();
  }

  void _addLog(String msg) {
    if (_consoleLogs.length > 50) _consoleLogs.removeAt(0);
    _consoleLogs.add(msg);
    notifyListeners();
  }

  @override
  void dispose() {
    _logSub?.cancel();
    _pipeline.stop();
    super.dispose();
  }
}
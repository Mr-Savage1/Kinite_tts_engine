class SpeakerData {
  static final List<String> _vctkList = List.generate(109, (i) => "VSpeaker #$i");

  static const Map<String, List<String>> _voiceMap = {
    "Kokoro": [
      "af_heart", "af_alloy", "af_aoede", "af_bella", "af_jessica",
      "af_kore", "af_nicole", "af_nova", "af_river", "af_sarah", "af_sky",
      "am_adam", "am_michael", "bf_emma", "bf_isabella", "bm_george", "bm_lewis"
    ],
    "Piper": ["en_US-Female"],
    "Kitten": [
      "1-Male", "1-Female", "2-Male", "2-Female",
      "3-Male", "3-Female", "4-Male", "4-Female"
    ],
  };

  static List<String> getVoices(String engine) {
    if (engine == "Coqui") return _vctkList;
    return _voiceMap[engine] ?? ["Default"];
  }

  static int getSid(String engine, String voiceName) {
    final voices = getVoices(engine);
    int index = voices.indexOf(voiceName);
    return index != -1 ? index : 0;
  }
}

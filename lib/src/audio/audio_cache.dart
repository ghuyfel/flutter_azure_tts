import 'dart:typed_data';
import 'package:flutter_azure_tts/src/common/cache_manager.dart';

/// Cache for audio data to avoid redundant API calls
class AudioCache {
  static const Duration _defaultTtl = Duration(hours: 1);
  final CacheManager _cache = CacheManager();

  String _generateKey(String text, String voiceShortName, String audioFormat, double rate) {
    return 'audio_${text.hashCode}_${voiceShortName}_${audioFormat}_$rate';
  }

  void put(String text, String voiceShortName, String audioFormat, double rate, Uint8List audio) {
    final key = _generateKey(text, voiceShortName, audioFormat, rate);
    _cache.put(key, audio, _defaultTtl);
  }

  Uint8List? get(String text, String voiceShortName, String audioFormat, double rate) {
    final key = _generateKey(text, voiceShortName, audioFormat, rate);
    return _cache.get<Uint8List>(key);
  }

  void clear() {
    _cache.clear();
  }
}
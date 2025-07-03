import 'package:flutter_azure_tts/src/voices/voices.dart';

/// Utility class for filtering voices with a fluent API
class VoiceFilter {
  VoiceFilter(this._voices);
  
  final List<Voice> _voices;

  VoiceFilter byLocale(String locale) {
    return VoiceFilter(
      _voices.where((voice) => voice.locale.startsWith(locale)).toList(),
    );
  }

  VoiceFilter byGender(String gender) {
    return VoiceFilter(
      _voices.where((voice) => voice.gender.toLowerCase() == gender.toLowerCase()).toList(),
    );
  }

  VoiceFilter withStyles() {
    return VoiceFilter(
      _voices.where((voice) => voice.styles.isNotEmpty).toList(),
    );
  }

  VoiceFilter withRoles() {
    return VoiceFilter(
      _voices.where((voice) => voice.roles.isNotEmpty).toList(),
    );
  }

  VoiceFilter withStyle(VoiceStyle style) {
    return VoiceFilter(
      _voices.where((voice) => voice.styles.contains(style)).toList(),
    );
  }

  VoiceFilter withRole(VoiceRole role) {
    return VoiceFilter(
      _voices.where((voice) => voice.roles.contains(role)).toList(),
    );
  }

  VoiceFilter neural() {
    return VoiceFilter(
      _voices.where((voice) => voice.voiceType.toLowerCase() == 'neural').toList(),
    );
  }

  VoiceFilter search(String query) {
    final lowerQuery = query.toLowerCase();
    return VoiceFilter(
      _voices.where((voice) => 
        voice.displayName.toLowerCase().contains(lowerQuery) ||
        voice.shortName.toLowerCase().contains(lowerQuery) ||
        voice.localName.toLowerCase().contains(lowerQuery)
      ).toList(),
    );
  }

  List<Voice> get results => List.unmodifiable(_voices);
  
  Voice? get first => _voices.isEmpty ? null : _voices.first;
  
  Voice get firstOrThrow {
    if (_voices.isEmpty) {
      throw StateError('No voices found matching the criteria');
    }
    return _voices.first;
  }

  int get length => _voices.length;
  bool get isEmpty => _voices.isEmpty;
  bool get isNotEmpty => _voices.isNotEmpty;
}

extension VoiceListExtensions on List<Voice> {
  VoiceFilter filter() => VoiceFilter(this);
}
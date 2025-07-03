import 'package:flutter_azure_tts/src/audio/audio_output_format.dart';
import 'package:flutter_azure_tts/src/ssml/style_ssml.dart';
import 'package:flutter_azure_tts/src/tts/tts_params.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';

/// Builder pattern for TtsParams with validation
class TtsParamsBuilder {
  Voice? _voice;
  String? _text;
  String? _audioFormat;
  double? _rate;
  StyleSsml? _style;
  VoiceRole? _role;

  TtsParamsBuilder voice(Voice voice) {
    _voice = voice;
    return this;
  }

  TtsParamsBuilder text(String text) {
    if (text.isEmpty) {
      throw ArgumentError('Text cannot be empty');
    }
    if (text.length > 10000) {
      throw ArgumentError('Text cannot exceed 10,000 characters');
    }
    _text = text;
    return this;
  }

  TtsParamsBuilder audioFormat(String format) {
    _audioFormat = format;
    return this;
  }

  TtsParamsBuilder rate(double rate) {
    if (rate < 0.5 || rate > 3.0) {
      throw ArgumentError('Rate must be between 0.5 and 3.0');
    }
    _rate = rate;
    return this;
  }

  TtsParamsBuilder style(StyleSsml style) {
    _style = style;
    return this;
  }

  TtsParamsBuilder role(VoiceRole role) {
    _role = role;
    return this;
  }

  TtsParams build() {
    final voice = _voice;
    final text = _text;
    final audioFormat = _audioFormat;

    if (voice == null) {
      throw ArgumentError('Voice is required');
    }
    if (text == null) {
      throw ArgumentError('Text is required');
    }
    if (audioFormat == null) {
      throw ArgumentError('Audio format is required');
    }

    // Validate style compatibility
    if (_style != null && !voice.styles.contains(_style!.style)) {
      throw ArgumentError('Voice ${voice.shortName} does not support style ${_style!.style}');
    }

    // Validate role compatibility
    if (_role != null && !voice.roles.contains(_role!)) {
      throw ArgumentError('Voice ${voice.shortName} does not support role $_role');
    }

    return TtsParams(
      voice: voice,
      audioFormat: audioFormat,
      text: text,
      rate: _rate,
      style: _style,
      role: _role,
    );
  }
}
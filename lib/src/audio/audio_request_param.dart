import 'package:flutter_azure_tts/src/voices/voices.dart';

class AudioRequestParams {
  final Voice voice;
  final String text;
  final String audioFormat;
  final double? rate;
  final String? style;
  final String? role;

  /// A number between 0.01 and 2.0. The degree to which to apply [style].
  final double? styleDegree;

  const AudioRequestParams({
    required this.voice,
    required this.text,
    required this.audioFormat,
    this.rate,
    this.style,
    this.role,
    this.styleDegree,
  });
}

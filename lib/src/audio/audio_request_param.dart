import 'package:flutter_azure_tts/src/voices/voices.dart';

class AudioRequestParams {
  final Voice voice;
  final String text;
  final String audioFormat;

  AudioRequestParams(
      {required this.voice, required this.text, required this.audioFormat});
}

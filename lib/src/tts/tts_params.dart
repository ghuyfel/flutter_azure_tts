import 'package:flutter_azure_tts/src/audio/audio_request_param.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';

class TtsParams extends AudioRequestParams {
  TtsParams({required Voice voice, required String audioFormat, required text})
      : super(audioFormat: audioFormat, text: text, voice: voice);
}

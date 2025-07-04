import 'package:flutter_azure_tts/src/audio/core/audio_request_param.dart';

class TtsParams extends AudioRequestParams {
  const TtsParams({
    required super.voice,
    required super.audioFormat,
    required super.text,
    super.rate,
    super.style,
    super.role,
  });
}

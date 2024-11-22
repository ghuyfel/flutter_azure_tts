import 'package:flutter_azure_tts/src/audio/audio_request_param.dart';

class TtsParams extends AudioRequestParams {
  /// Rate is the speed at which the voice will speak.
  ///
  /// * `rate` defaults to 1.

  const TtsParams({
    required super.voice,
    required super.audioFormat,
    required super.text,
    super.rate,
    super.style,
    super.role,
    super.styleDegree,
  });
}

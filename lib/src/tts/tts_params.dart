import 'package:flutter_azure_tts/src/audio/audio_request_param.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';

class TtsParams extends AudioRequestParams {
  /// Rate is the speed at which the voice will speak.
  ///
  /// * `rate` default to 1.

  TtsParams({
    required Voice voice,
    required String audioFormat,
    required text,
    double? rate,
  }) : super(
          audioFormat: audioFormat,
          text: text,
          voice: voice,
          rate: rate,
        );
}

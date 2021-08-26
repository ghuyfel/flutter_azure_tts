library flutter_azure_tts;

import 'package:flutter_azure_tts/src/audio/audio_responses.dart';
import 'package:flutter_azure_tts/src/tts/tts.dart';
import 'package:flutter_azure_tts/src/tts/tts_params.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';

export '/src/audio/audio.dart';
export '/src/auth/auth.dart';
export '/src/voices/voices.dart';
export '/src/common/common.dart';
export "/src/tts/tts_params.dart";

class AzureTts {
  ///Initialises the framework. Throws an [AzureException] on failure.
  static Future<bool> init(
      {required String subscriptionKey, required String region}) async {
    return Tts.init(region: region, subscriptionKey: subscriptionKey);
  }

  ///Returns available voices. Throws an [AzureException] on failure.
  static Future<VoicesResponse> getAvailableVoices() async {
    return Tts.getAvailableVoices();
  }

  ///Converts text to speech and return audio file as [Uint8List]. Throws an [AzureException] on failure.
  static Future<AudioResponse> getTts(TtsParams params) async {
    return Tts.getTts(params);
  }
}

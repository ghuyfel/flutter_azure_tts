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
  ///Initialises the framework.
  ///
  /// **region** : Azure endpoint region
  ///
  /// **subscriptionKey** : Azure subscription key
  ///
  /// **withLogs** : (optional) enable logs. *true* by default
  ///
  ///Throws an [AzureException] on failure.
  static void init(
      {required String subscriptionKey, required String region, bool withLogs = true}) async {
    Tts.init(region: region, subscriptionKey: subscriptionKey, withLogs: withLogs);
  }

  ///Get available voices on the Azure Endpoint Region
  ///
  ///Returns [VoicesResponse]
  ///
  /// [VoicesSuccess] request succeeded
  ///
  /// On failure returns one of the following:
  /// [VoicesFailedBadRequest], [VoicesFailedBadRequest], [VoicesFailedUnauthorized],
  /// [VoicesFailedTooManyRequests], [VoicesFailedBadGateWay], [VoicesFailedUnkownError]
  ///
  ///Throws an [AzureException] if something goes wrong.
  static Future<VoicesResponse> getAvailableVoices() async {
    return Tts.getAvailableVoices();
  }

  ///Converts text to speech and return audio file as [Uint8List].
  ///
  /// [ttsParams] request parameters
  ///
  /// Returns [AudioResponse]
  ///
  /// [AudioSuccess] request succeeded
  ///
  /// On failure returns one of the following:
  /// [AudioFailedBadRequest], [AudioFailedUnauthorized], [AudioFailedUnsupported], [AudioFailedTooManyRequest],
  /// [AudioFailedBadGateway], [AudioFailedBadGateway], [AudioFailedUnkownError]
  ///
  ///Throws an [AzureException] if something goes wrong.
  static Future<AudioResponse> getTts(TtsParams params) async {
    return Tts.getTts(params);
  }
}

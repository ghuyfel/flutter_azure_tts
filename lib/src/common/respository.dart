import 'dart:async';

import 'package:flutter_azure_tts/src/audio/audio.dart';
import 'package:flutter_azure_tts/src/audio/audio_handler.dart';
import 'package:flutter_azure_tts/src/auth/auth.dart';
import 'package:flutter_azure_tts/src/auth/auth_handler.dart';
import 'package:flutter_azure_tts/src/auth/auth_token.dart';
import 'package:flutter_azure_tts/src/common/azure_exception.dart';
import 'package:flutter_azure_tts/src/common/config.dart';
import 'package:flutter_azure_tts/src/tts/tts_params.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';
import 'package:flutter_azure_tts/src/voices/voices_handler.dart';

///Implements repository pattern to acces Azure resources
class Repository {
  Repository(
      {required this.authHandler,
      required this.voicesHandler,
      required this.audioHandler});

  final AuthHandler authHandler;
  final VoicesHandler voicesHandler;
  final AudioHandler audioHandler;

  ///Get available voices on the Azure endpoint region
  ///
  ///Returns [VoicesResponse]
  ///
  /// [VoicesSuccess] request succeeded
  ///
  /// On failure returns one of the following:
  /// [VoicesFailedBadRequest], [VoicesFailedBadRequest], [VoicesFailedUnauthorized],
  /// [VoicesFailedTooManyRequests], [VoicesFailedBadGateWay], [VoicesFailedUnkownError]
  Future<VoicesResponse> getAvailableVoices() async {
    await assureTokenIsValid();
    return await voicesHandler.getVoices();
  }

  ///Get audio for transcription
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
  Future<AudioResponse> getTts(TtsParams ttsParams) async {
    await assureTokenIsValid();
    return await audioHandler.getAudio(ttsParams);
  }

  ///Checks if there is a valid token.
  ///Requests a new token if no valid token is found.
  ///
  /// Returns *true* if a valid token exists.
  ///
  ///Throws [AzureException] if token request fails.
  Future<bool> assureTokenIsValid() async {
    final completer = Completer<bool>();
    if (Config.authToken == null || Config.authToken!.isExpired) {
      final authResponse = await authHandler.getAuthToken();
      if (authResponse is TokenSuccess) {
        Config.authToken = AuthToken(token: authResponse.token);
        completer.complete(true);
      } else {
        throw AzureException(response: authResponse);
      }
    } else {
      completer.complete(true);
    }
    return completer.future;
  }
}

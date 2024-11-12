import 'package:azure_tts/azure_tts.dart';
import 'package:azure_tts/src/audio/audio_handler.dart';
import 'package:azure_tts/src/auth/auth_client.dart';
import 'package:azure_tts/src/auth/auth_handler.dart';
import 'package:azure_tts/src/auth/auth_response_mapper.dart';
import 'package:azure_tts/src/auth/authentication_types.dart';
import 'package:azure_tts/src/common/config.dart';
import 'package:azure_tts/src/common/respository.dart';
import 'package:azure_tts/src/utils/log.dart';
import 'package:azure_tts/src/voices/voices_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

///Helper class for Azure Cognitive TTS requests
class Tts {
  static late final AuthHandler _authHandler;
  static final AudioHandler _audioHandler = AudioHandler();
  static final VoicesHandler _voicesHandler = VoicesHandler();
  static late final Repository repo;

  /// MUST be called first before any other call is made.
  ///
  /// **region** : Azure endpoint region
  ///
  /// **subscriptionKey** : Azure subscription key
  ///
  /// **withLogs** : (optional) enable logs. *true* by default
  ///
  static void init(
          {required String region,
          required String subscriptionKey,
          bool withLogs = true}) =>
      _init(region, subscriptionKey, withLogs);

  ///Get available voices on the Azure Endpoint Region
  ///
  ///Returns [VoicesSuccess]
  ///
  /// [VoicesSuccess] request succeeded
  ///
  /// On failure throws one of the following:
  /// [VoicesFailedBadRequest], [VoicesFailedBadRequest], [VoicesFailedUnauthorized],
  /// [VoicesFailedTooManyRequests], [VoicesFailedBadGateWay], [VoicesFailedUnkownError] or [AzureException]
  static Future<VoicesSuccess> getAvailableVoices() async {
    return repo.getAvailableVoices();
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
  static Future<AudioSuccess> getTts(TtsParams ttsParams) async {
    return repo.getTts(ttsParams);
  }

  static void _init(String region, String subscriptionKey,
      [bool withLogs = true]) {
    EquatableConfig.stringify = true;
    Config.init(endpointRegion: region, endpointSubKey: subscriptionKey);
    _initAuthManager();
    _initRepository();
    _initLogs(withLogs);
    Log.d("package initialised");
  }

  static void _initAuthManager() {
    final client = http.Client();

    final authHeader = SubscriptionKeyAuthenticationHeader(
        subscriptionKey: Config.subscriptionKey);

    final authClient = AuthClient(client: client, authHeader: authHeader);

    final authResponseMapper = AuthResponseMapper();

    _authHandler =
        AuthHandler(authClient: authClient, mapper: authResponseMapper);
  }

  static void _initRepository() {
    repo = Repository(
        authHandler: _authHandler,
        voicesHandler: _voicesHandler,
        audioHandler: _audioHandler);
  }

  static void _initLogs(bool withLogs) =>
      withLogs ? Log.enable() : Log.disable();
}

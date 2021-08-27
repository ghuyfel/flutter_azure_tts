import 'package:equatable/equatable.dart';
import 'package:flutter_azure_tts/src/audio/audio_handler.dart';
import 'package:flutter_azure_tts/src/audio/audio_responses.dart';
import 'package:flutter_azure_tts/src/auth/auth_handler.dart';
import 'package:flutter_azure_tts/src/tts/tts_params.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';
import 'package:flutter_azure_tts/src/voices/voices_handler.dart';

import '../common/config.dart';

class Tts {
  static final AuthHandler _authHandler = AuthHandler();
  static final AudioHandler _audioHandler = AudioHandler();
  static final VoicesHandler _voicesHandler = VoicesHandler();
  static bool _initialised = false;

  static Future<bool> init(
      {required String region, required String subscriptionKey}) async {
    EquatableConfig.stringify = true;
    Config.init(endpointRegion: region, endpointSubKey: subscriptionKey);
    _initialised = await _authHandler.init();
    return _initialised;
  }

  static Future<VoicesResponse> getAvailableVoices() async {
    final response = await _voicesHandler.getVoices();
    return response;
  }

  static Future<AudioResponse> getTts(TtsParams ttsParams) async {
    final response = await _audioHandler.getAudio(ttsParams);
    return response;
  }
}

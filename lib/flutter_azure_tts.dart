library flutter_azure_tts;

import 'package:flutter_azure_tts/src/audio/audio_responses.dart';
import 'package:flutter_azure_tts/src/common/azure_tts_config.dart';
import 'package:flutter_azure_tts/src/common/azure_tts_exception.dart';
import 'package:flutter_azure_tts/src/tts/tts.dart';
import 'package:flutter_azure_tts/src/tts/tts_params.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';

export '/src/audio/audio.dart';
export '/src/auth/auth.dart';
export '/src/voices/voices.dart';
export '/src/common/common.dart';
export "/src/tts/tts_params.dart";
export '/src/tts/tts_params_builder.dart';
export '/src/ssml/style_ssml.dart';
export '/src/voices/voice_filter.dart';
export '/src/common/azure_tts_exception.dart';
export '/src/common/retry_policy.dart';

/// Main entry point for Azure Text-to-Speech functionality
class FlutterAzureTts {
  FlutterAzureTts._(); // Private constructor to prevent instantiation

  /// Initializes the Azure TTS framework with improved configuration
  /// 
  /// Throws [InitializationException] if configuration is invalid
  static void init({
    required String subscriptionKey,
    required String region,
    bool withLogs = true,
    RetryPolicy? retryPolicy,
    Duration? requestTimeout,
  }) {
    try {
      final config = AzureTtsConfig.create(
        subscriptionKey: subscriptionKey,
        region: region,
        withLogs: withLogs,
        retryPolicy: retryPolicy,
        requestTimeout: requestTimeout,
      );
      
      ConfigManager().setConfig(config);
      
      Tts.init(
        region: region,
        subscriptionKey: subscriptionKey,
        withLogs: withLogs,
      );
    } catch (e) {
      throw InitializationException('Failed to initialize Azure TTS', e);
    }
  }

  /// Gets available voices with improved error handling
  /// 
  /// Returns [VoicesSuccess] on success
  /// Throws [AzureTtsException] on failure
  static Future<VoicesSuccess> getAvailableVoices() async {
    if (!ConfigManager().isInitialized) {
      throw InitializationException('Azure TTS not initialized. Call init() first.');
    }
    
    try {
      return await Tts.getAvailableVoices();
    } catch (e) {
      if (e is AzureTtsException) rethrow;
      throw NetworkException('Failed to get available voices', e);
    }
  }

  /// Converts text to speech with improved error handling
  /// 
  /// Returns [AudioSuccess] on success
  /// Throws [AzureTtsException] on failure
  static Future<AudioSuccess> getTts(TtsParams params) async {
    if (!ConfigManager().isInitialized) {
      throw InitializationException('Azure TTS not initialized. Call init() first.');
    }
    
    try {
      return await Tts.getTts(params);
    } catch (e) {
      if (e is AzureTtsException) rethrow;
      throw NetworkException('Failed to generate speech', e);
    }
  }

  /// Checks if the framework is properly initialized
  static bool get isInitialized => ConfigManager().isInitialized;

  /// Gets the current configuration (read-only)
  static AzureTtsConfig get config => ConfigManager().config;
}
library flutter_azure_tts;

import 'package:flutter_azure_tts/src/audio/core/audio_responses.dart';
import 'package:flutter_azure_tts/src/audio/streaming/audio_stream.dart';
import 'package:flutter_azure_tts/src/audio/handlers/audio_stream_handler.dart';
import 'package:flutter_azure_tts/src/common/azure_tts_config.dart';
import 'package:flutter_azure_tts/src/common/azure_tts_exception.dart';
import 'package:flutter_azure_tts/src/common/retry_policy.dart';
import 'package:flutter_azure_tts/src/tts/tts.dart';
import 'package:flutter_azure_tts/src/tts/tts_params.dart';
import 'package:flutter_azure_tts/src/tts/tts_streaming_params.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';

export '/src/audio/audio.dart';
export '/src/auth/auth.dart';
export '/src/voices/voices.dart';
export '/src/common/common.dart';
export "/src/tts/tts_params.dart";
export '/src/tts/tts_params_builder.dart';
export '/src/tts/tts_streaming_params.dart';
export '/src/tts/tts_streaming_params_builder.dart';
export '/src/audio/streaming/audio_stream.dart';
export '/src/ssml/style_ssml.dart';
export '/src/voices/voice_filter.dart';
export '/src/common/azure_tts_exception.dart';
export '/src/common/retry_policy.dart';

/// Main entry point for Azure Text-to-Speech functionality.
/// 
/// This class provides a simplified interface to Microsoft Azure's Cognitive Services
/// Text-to-Speech API. It handles authentication, voice management, and audio generation
/// with built-in error handling, caching, and retry mechanisms.
/// 
/// ## Features
/// 
/// - **Standard TTS**: Generate complete audio files
/// - **Streaming TTS**: Real-time audio streaming for lower latency
/// - **Authentication Management**: Automatic token refresh and validation
/// - **Voice Filtering**: Advanced filtering capabilities for finding the right voice
/// - **Error Handling**: Comprehensive exception hierarchy for different error types
/// - **Caching**: Built-in caching for voices and audio to reduce API calls
/// - **Retry Logic**: Configurable retry policies with exponential backoff
/// - **Validation**: Input validation for all parameters
/// 
/// ## Usage
/// 
/// First, initialize the service with your Azure credentials:
/// ```dart
/// FlutterAzureTts.init(
///   subscriptionKey: 'your-subscription-key',
///   region: 'your-region',
///   withLogs: true,
/// );
/// ```
/// 
/// Then get available voices and generate speech:
/// ```dart
/// final voices = await FlutterAzureTts.getAvailableVoices();
/// final voice = voices.voices.first;
/// 
/// // Standard TTS (complete audio file)
/// final params = TtsParamsBuilder()
///     .voice(voice)
///     .text('Hello, world!')
///     .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
///     .build();
/// 
/// final audio = await FlutterAzureTts.getTts(params);
/// 
/// // Streaming TTS (real-time audio chunks)
/// final streamingParams = TtsStreamingParamsBuilder()
///     .voice(voice)
///     .text('Hello, streaming world!')
///     .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
///     .preferredChunkSize(ChunkSize.small)
///     .bufferStrategy(BufferStrategy.lowLatency)
///     .build();
/// 
/// final audioStream = await FlutterAzureTts.getTtsStream(streamingParams);
/// await for (final chunk in audioStream.audioStream) {
///   // Process audio chunk in real-time
///   audioPlayer.addChunk(chunk.data);
/// }
/// ```
/// 
/// ## Thread Safety
/// 
/// This class is thread-safe and can be used from multiple isolates simultaneously.
/// The underlying configuration and authentication state is managed through
/// thread-safe singletons.
class FlutterAzureTts {
  /// Private constructor to prevent instantiation.
  /// This class is designed to be used as a static interface only.
  FlutterAzureTts._();

  /// Audio stream handler for streaming TTS requests.
  static final AudioStreamHandler _audioStreamHandler = AudioStreamHandler();

  /// Initializes the Azure TTS framework with improved configuration.
  /// 
  /// This method must be called before any other operations. It sets up the
  /// authentication, configuration, and internal services required for
  /// text-to-speech operations.
  /// 
  /// ## Parameters
  /// 
  /// - [subscriptionKey]: Your Azure Cognitive Services subscription key.
  ///   Must be a valid 32-character key from your Azure portal.
  /// - [region]: The Azure region where your service is deployed (e.g., 'eastus', 'westeurope').
  /// - [withLogs]: Whether to enable debug logging. Defaults to `true`.
  /// - [retryPolicy]: Custom retry policy for failed requests. If not provided,
  ///   uses default policy with 3 retries and exponential backoff.
  /// - [requestTimeout]: Timeout for individual HTTP requests. Defaults to 30 seconds.
  /// 
  /// ## Throws
  /// 
  /// - [InitializationException]: If the configuration is invalid or initialization fails.
  /// - [ArgumentError]: If required parameters are missing or invalid.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// FlutterAzureTts.init(
  ///   subscriptionKey: 'your-32-char-subscription-key',
  ///   region: 'eastus',
  ///   withLogs: true,
  ///   retryPolicy: RetryPolicy(
  ///     maxRetries: 5,
  ///     baseDelay: Duration(milliseconds: 1000),
  ///   ),
  ///   requestTimeout: Duration(seconds: 45),
  /// );
  /// ```
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

  /// Gets available voices from Azure with improved error handling.
  /// 
  /// Retrieves the complete list of voices available in your Azure region.
  /// The result includes voice metadata such as supported languages, genders,
  /// styles, and roles. Results are automatically cached to improve performance.
  /// 
  /// ## Returns
  /// 
  /// A [VoicesSuccess] object containing the list of available voices.
  /// Each voice includes:
  /// - Basic information (name, locale, gender)
  /// - Technical details (sample rate, voice type)
  /// - Capabilities (supported styles and roles)
  /// 
  /// ## Throws
  /// 
  /// - [InitializationException]: If the service hasn't been initialized.
  /// - [AuthenticationException]: If authentication fails.
  /// - [NetworkException]: If the network request fails.
  /// - [ServiceUnavailableException]: If Azure services are temporarily unavailable.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// try {
  ///   final voicesResponse = await FlutterAzureTts.getAvailableVoices();
  ///   print('Found ${voicesResponse.voices.length} voices');
  ///   
  ///   // Filter for English neural voices with styles
  ///   final englishVoices = voicesResponse.voices
  ///       .filter()
  ///       .byLocale('en-')
  ///       .neural()
  ///       .withStyles()
  ///       .results;
  /// } on NetworkException catch (e) {
  ///   print('Network error: ${e.message}');
  /// }
  /// ```
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

  /// Converts text to speech with improved error handling and validation.
  /// 
  /// Generates audio from the provided text using the specified voice and parameters.
  /// The method includes comprehensive validation, automatic retries on failure,
  /// and optional caching to improve performance for repeated requests.
  /// 
  /// ## Parameters
  /// 
  /// - [params]: The text-to-speech parameters created using [TtsParamsBuilder].
  ///   Must include at minimum: voice, text, and audio format.
  /// 
  /// ## Returns
  /// 
  /// An [AudioSuccess] object containing the generated audio data as bytes.
  /// The audio format matches the format specified in the parameters.
  /// 
  /// ## Throws
  /// 
  /// - [InitializationException]: If the service hasn't been initialized.
  /// - [ValidationException]: If the parameters are invalid.
  /// - [AuthenticationException]: If authentication fails.
  /// - [NetworkException]: If the network request fails.
  /// - [RateLimitException]: If you've exceeded the API rate limits.
  /// - [ServiceUnavailableException]: If Azure services are temporarily unavailable.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// try {
  ///   final params = TtsParamsBuilder()
  ///       .voice(selectedVoice)
  ///       .text('Hello, this is a test of Azure TTS!')
  ///       .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
  ///       .rate(1.2)
  ///       .style(StyleSsml(style: VoiceStyle.cheerful))
  ///       .build();
  ///   
  ///   final audioResponse = await FlutterAzureTts.getTts(params);
  ///   
  ///   // Save or play the audio
  ///   await File('output.mp3').writeAsBytes(audioResponse.audio);
  /// } on ValidationException catch (e) {
  ///   print('Invalid parameters: ${e.message}');
  /// } on RateLimitException catch (e) {
  ///   print('Rate limited. Retry after: ${e.retryAfter}');
  /// }
  /// ```
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

  /// Converts text to speech using streaming for real-time audio delivery.
  /// 
  /// This method provides streaming audio generation, allowing audio playback
  /// to start immediately as chunks become available rather than waiting for
  /// the complete audio file. This significantly reduces perceived latency
  /// and improves user experience for interactive applications.
  /// 
  /// ## Benefits of Streaming
  /// 
  /// - **Lower Latency**: Audio playback can start within milliseconds
  /// - **Better User Experience**: No waiting for long texts to be fully processed
  /// - **Memory Efficiency**: Audio is processed in chunks rather than loading everything
  /// - **Real-time Feedback**: Progress can be shown to users
  /// - **Scalability**: Better performance for concurrent requests
  /// 
  /// ## Parameters
  /// 
  /// - [params]: The streaming TTS parameters created using [TtsStreamingParamsBuilder].
  ///   Includes all standard TTS parameters plus streaming-specific options.
  /// 
  /// ## Returns
  /// 
  /// An [AudioStreamResponse] containing:
  /// - A stream of [AudioChunk] objects as they become available
  /// - Content type information
  /// - Estimated total size (if available)
  /// 
  /// ## Throws
  /// 
  /// - [InitializationException]: If the service hasn't been initialized.
  /// - [ValidationException]: If the parameters are invalid for streaming.
  /// - [AuthenticationException]: If authentication fails.
  /// - [NetworkException]: If the streaming request fails.
  /// - [RateLimitException]: If you've exceeded the API rate limits.
  /// - [ServiceUnavailableException]: If Azure services are temporarily unavailable.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// try {
  ///   final streamingParams = TtsStreamingParamsBuilder()
  ///       .voice(selectedVoice)
  ///       .text('This is streaming audio that will play in real-time!')
  ///       .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
  ///       .preferredChunkSize(ChunkSize.small)
  ///       .bufferStrategy(BufferStrategy.lowLatency)
  ///       .enableProgressTracking(true)
  ///       .build();
  ///   
  ///   final audioStreamResponse = await FlutterAzureTts.getTtsStream(streamingParams);
  ///   
  ///   // Process audio chunks in real-time
  ///   await for (final chunk in audioStreamResponse.audioStream) {
  ///     print('Received chunk ${chunk.sequenceNumber}: ${chunk.size} bytes');
  ///     
  ///     // Add chunk to audio player for immediate playback
  ///     audioPlayer.addChunk(chunk.data);
  ///     
  ///     if (chunk.isLast) {
  ///       print('Streaming completed');
  ///       break;
  ///     }
  ///   }
  /// } on ValidationException catch (e) {
  ///   print('Invalid streaming parameters: ${e.message}');
  /// } on NetworkException catch (e) {
  ///   print('Streaming failed: ${e.message}');
  /// }
  /// ```
  /// 
  /// ## Advanced Usage with Progress Tracking
  /// 
  /// ```dart
  /// final streamingParams = TtsStreamingParamsBuilder.forRealtime()
  ///     .voice(voice)
  ///     .text(longText)
  ///     .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
  ///     .build();
  /// 
  /// final (audioStream, progressStream) = await FlutterAzureTts.getTtsStreamWithProgress(streamingParams);
  /// 
  /// // Listen to progress updates for UI
  /// progressStream.listen((progress) {
  ///   final percent = progress.percentComplete ?? 0.0;
  ///   updateProgressBar(percent);
  ///   print('Progress: ${(percent * 100).toStringAsFixed(1)}%');
  /// });
  /// 
  /// // Process audio chunks
  /// await for (final chunk in audioStream.audioStream) {
  ///   audioPlayer.addChunk(chunk.data);
  /// }
  /// ```
  static Future<AudioStreamResponse> getTtsStream(TtsStreamingParams params) async {
    if (!ConfigManager().isInitialized) {
      throw InitializationException('Azure TTS not initialized. Call init() first.');
    }
    
    try {
      // Validate streaming parameters
      _audioStreamHandler.validateStreamingParams(params);
      
      // Get streaming audio
      return await _audioStreamHandler.getAudioStream(params);
    } catch (e) {
      if (e is AzureTtsException) rethrow;
      throw NetworkException('Failed to initiate streaming TTS', e);
    }
  }

  /// Converts text to speech using streaming with detailed progress tracking.
  /// 
  /// This method provides the same streaming functionality as [getTtsStream]
  /// but includes a separate stream of progress information that can be used
  /// for UI updates, analytics, or debugging.
  /// 
  /// ## Parameters
  /// 
  /// - [params]: The streaming TTS parameters with progress tracking enabled.
  /// 
  /// ## Returns
  /// 
  /// A tuple containing:
  /// - [AudioStreamResponse]: The audio stream
  /// - [Stream<StreamProgress>]: Detailed progress information
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final (audioStream, progressStream) = await FlutterAzureTts.getTtsStreamWithProgress(params);
  /// 
  /// // Monitor progress
  /// progressStream.listen((progress) {
  ///   print('Received ${progress.bytesReceived} bytes');
  ///   print('Speed: ${progress.bytesPerSecond.toStringAsFixed(1)} B/s');
  ///   if (progress.percentComplete != null) {
  ///     print('Progress: ${(progress.percentComplete! * 100).toStringAsFixed(1)}%');
  ///   }
  /// });
  /// 
  /// // Process audio
  /// await for (final chunk in audioStream.audioStream) {
  ///   audioPlayer.addChunk(chunk.data);
  /// }
  /// ```
  static Future<(AudioStreamResponse, Stream<StreamProgress>)> getTtsStreamWithProgress(
    TtsStreamingParams params,
  ) async {
    if (!ConfigManager().isInitialized) {
      throw InitializationException('Azure TTS not initialized. Call init() first.');
    }
    
    try {
      // Validate streaming parameters
      _audioStreamHandler.validateStreamingParams(params);
      
      // Get streaming audio with progress
      return await _audioStreamHandler.getAudioStreamWithProgress(params);
    } catch (e) {
      if (e is AzureTtsException) rethrow;
      throw NetworkException('Failed to initiate streaming TTS with progress', e);
    }
  }

  /// Checks if the framework is properly initialized.
  /// 
  /// Returns `true` if [init] has been called successfully and the service
  /// is ready to use. Returns `false` if initialization is required.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// if (!FlutterAzureTts.isInitialized) {
  ///   FlutterAzureTts.init(
  ///     subscriptionKey: 'your-key',
  ///     region: 'your-region',
  ///   );
  /// }
  /// ```
  static bool get isInitialized => ConfigManager().isInitialized;

  /// Gets the current configuration (read-only).
  /// 
  /// Returns the current [AzureTtsConfig] instance containing all configuration
  /// settings including subscription key, region, retry policies, and timeouts.
  /// 
  /// ## Throws
  /// 
  /// - [StateError]: If the service hasn't been initialized yet.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final config = FlutterAzureTts.config;
  /// print('Current region: ${config.region}');
  /// print('Request timeout: ${config.requestTimeout}');
  /// ```
  static AzureTtsConfig get config => ConfigManager().config;
}
import 'dart:async';

import 'package:flutter_azure_tts/src/common/azure_tts_exception.dart';
import 'package:flutter_azure_tts/src/audio/core/audio_request_param.dart';
import 'package:flutter_azure_tts/src/audio/streaming/audio_stream.dart';
import 'package:flutter_azure_tts/src/audio/client/audio_stream_client.dart';
import 'package:flutter_azure_tts/src/audio/core/audio_type_header.dart';
import 'package:flutter_azure_tts/src/auth/authentication_types.dart';
import 'package:flutter_azure_tts/src/common/azure_tts_config.dart';
import 'package:flutter_azure_tts/src/common/constants.dart';
import 'package:flutter_azure_tts/src/ssml/ssml.dart';
import 'package:http/http.dart' as http;

/// Handler for streaming audio requests to Azure Text-to-Speech service.
/// 
/// This class manages the complexities of streaming audio generation, including
/// request formatting, connection management, and stream processing. It provides
/// a high-level interface for streaming TTS operations while handling the
/// low-level details of the Azure API.
/// 
/// ## Features
/// 
/// - **Real-time Streaming**: Audio chunks delivered as they're generated
/// - **Connection Management**: Robust connection handling with retries
/// - **Progress Tracking**: Real-time progress information
/// - **Error Recovery**: Automatic retry on transient failures
/// - **Memory Efficiency**: Processes audio in chunks rather than loading everything
/// 
/// ## Azure TTS Streaming
/// 
/// Azure TTS streaming works by:
/// 1. Sending SSML content to the streaming endpoint
/// 2. Receiving audio data in chunks via HTTP streaming
/// 3. Processing chunks in real-time for immediate playback
/// 4. Handling metadata and timing information
/// 
/// ## Usage
/// 
/// This handler is used internally by the main Azure TTS library:
/// 
/// ```dart
/// final handler = AudioStreamHandler();
/// final streamResponse = await handler.getAudioStream(params);
/// 
/// await for (final chunk in streamResponse.audioStream) {
///   // Process audio chunk in real-time
///   audioPlayer.addChunk(chunk.data);
/// }
/// ```
class AudioStreamHandler {
  /// Creates a new audio stream handler.
  AudioStreamHandler();

  /// Initiates a streaming audio request to Azure TTS.
  /// 
  /// This method creates a streaming connection to Azure TTS and returns
  /// a stream of audio chunks as they become available. The stream starts
  /// emitting data as soon as the first audio chunk is received.
  /// 
  /// ## Parameters
  /// 
  /// - [params]: The TTS parameters including voice, text, and format
  /// 
  /// ## Returns
  /// 
  /// An [AudioStreamResponse] containing the stream of audio chunks.
  /// 
  /// ## Throws
  /// 
  /// - [InitializationException]: If the service hasn't been initialized
  /// - [AuthenticationException]: If authentication fails
  /// - [NetworkException]: If the streaming request fails
  /// - [ValidationException]: If the parameters are invalid
  /// - [RateLimitException]: If rate limits are exceeded
  /// - [ServiceUnavailableException]: If Azure service is unavailable
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final handler = AudioStreamHandler();
  /// 
  /// try {
  ///   final streamResponse = await handler.getAudioStream(ttsParams);
  ///   
  ///   await for (final chunk in streamResponse.audioStream) {
  ///     print('Received chunk ${chunk.sequenceNumber}: ${chunk.size} bytes');
  ///     
  ///     // Process chunk for real-time playback
  ///     audioPlayer.addChunk(chunk.data);
  ///     
  ///     if (chunk.isLast) {
  ///       print('Stream completed');
  ///       break;
  ///     }
  ///   }
  /// } catch (e) {
  ///   print('Streaming failed: $e');
  /// }
  /// ```
  Future<AudioStreamResponse> getAudioStream(AudioRequestParams params) async {
    // Get current configuration and auth token
    final config = ConfigManager().config;
    final authToken = ConfigManager().authToken;
    
    if (authToken == null || authToken.isExpired) {
      throw AuthenticationException('Authentication token is missing or expired');
    }

    // Create streaming client with proper headers
    final streamClient = AudioStreamClient(
      client: http.Client(),
      authHeader: BearerAuthenticationHeader(token: authToken.token),
      audioTypeHeader: AudioTypeHeader(audioFormat: params.audioFormat),
    );

    try {
      // Build SSML content for the request
      final ssml = Ssml(
        voice: params.voice,
        text: params.text,
        speed: params.rate ?? 1.0,
        style: params.style,
        role: params.role,
      );

      // Initiate streaming request
      final streamResponse = await streamClient.streamTts(
        Uri.parse(Endpoints.audio),
        ssml.buildSsml,
      );

      return streamResponse;
    } catch (e) {
      // Re-throw Azure TTS exceptions as-is
      if (e is AzureTtsException) rethrow;
      
      // Wrap other exceptions in NetworkException
      throw NetworkException('Failed to initiate audio streaming', e);
    }
  }

  /// Creates a streaming request with progress tracking.
  /// 
  /// This method provides the same streaming functionality as [getAudioStream]
  /// but includes detailed progress information that can be used for UI updates,
  /// analytics, or debugging.
  /// 
  /// ## Parameters
  /// 
  /// - [params]: The TTS parameters including voice, text, and format
  /// 
  /// ## Returns
  /// 
  /// A [Future] that completes with a tuple containing:
  /// - [AudioStreamResponse]: The audio stream
  /// - [Stream<StreamProgress>]: Progress information stream
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final handler = AudioStreamHandler();
  /// final (audioStream, progressStream) = await handler.getAudioStreamWithProgress(params);
  /// 
  /// // Listen to progress updates
  /// progressStream.listen((progress) {
  ///   print('Progress: ${progress.percentComplete}%');
  ///   print('Speed: ${progress.bytesPerSecond} bytes/sec');
  ///   updateProgressBar(progress.percentComplete ?? 0.0);
  /// });
  /// 
  /// // Process audio chunks
  /// await for (final chunk in audioStream.audioStream) {
  ///   audioPlayer.addChunk(chunk.data);
  /// }
  /// ```
  Future<(AudioStreamResponse, Stream<StreamProgress>)> getAudioStreamWithProgress(
    AudioRequestParams params,
  ) async {
    // Get the base audio stream
    final audioStreamResponse = await getAudioStream(params);
    
    // Create progress tracking
    final progressController = StreamController<StreamProgress>();
    final startTime = DateTime.now();
    int bytesReceived = 0;
    int chunksReceived = 0;
    bool isComplete = false;

    // Transform the audio stream to track progress
    final progressAudioStream = audioStreamResponse.audioStream.map((chunk) {
      if (!isComplete) {
        bytesReceived += chunk.data.length;
        chunksReceived++;
        
        if (chunk.isLast) {
          isComplete = true;
        }

        // Emit progress update
        final progress = StreamProgress(
          bytesReceived: bytesReceived,
          totalEstimatedBytes: audioStreamResponse.totalEstimatedSize,
          chunksReceived: chunksReceived,
          elapsedTime: DateTime.now().difference(startTime),
          isComplete: isComplete,
        );
        
        progressController.add(progress);
      }
      
      return chunk;
    });

    // Close progress stream when audio stream completes
    progressAudioStream.listen(
      null,
      onDone: () {
        if (!progressController.isClosed) {
          progressController.close();
        }
      },
      onError: (error) {
        if (!progressController.isClosed) {
          progressController.addError(error);
        }
      },
    );

    final enhancedAudioResponse = AudioStreamResponse(
      audioStream: progressAudioStream,
      contentType: audioStreamResponse.contentType,
      totalEstimatedSize: audioStreamResponse.totalEstimatedSize,
    );

    return (enhancedAudioResponse, progressController.stream);
  }

  /// Validates streaming parameters before making the request.
  /// 
  /// This method performs comprehensive validation of TTS parameters
  /// specifically for streaming requests, which may have different
  /// requirements than regular TTS requests.
  /// 
  /// ## Parameters
  /// 
  /// - [params]: The TTS parameters to validate
  /// 
  /// ## Throws
  /// 
  /// - [ValidationException]: If any parameters are invalid for streaming
  /// 
  /// ## Validation Rules
  /// 
  /// - Text length must be within Azure limits (≤ 10,000 characters)
  /// - Audio format must support streaming
  /// - Voice must be available and support requested features
  /// - Rate must be within valid range (0.5 - 3.0)
  /// - Style and role must be supported by the voice (if specified)
  void validateStreamingParams(AudioRequestParams params) {
    // Validate text length
    if (params.text.isEmpty) {
      throw ValidationException('Text cannot be empty for streaming TTS');
    }
    
    if (params.text.length > Constants.maxTextLength) {
      throw ValidationException(
        'Text length (${params.text.length}) exceeds maximum allowed '
        '(${Constants.maxTextLength}) for streaming TTS'
      );
    }

    // Validate speech rate
    final rate = params.rate ?? 1.0;
    if (rate < 0.5 || rate > 3.0) {
      throw ValidationException(
        'Speech rate ($rate) must be between 0.5 and 3.0 for streaming TTS'
      );
    }

    // Validate voice capabilities
    if (params.style != null && !params.voice.styles.contains(params.style!.style)) {
      throw ValidationException(
        'Voice "${params.voice.shortName}" does not support style "${params.style!.styleName}" for streaming TTS'
      );
    }

    if (params.role != null && !params.voice.roles.contains(params.role!)) {
      throw ValidationException(
        'Voice "${params.voice.shortName}" does not support role "${params.role}" for streaming TTS'
      );
    }

    // Validate audio format for streaming
    _validateStreamingAudioFormat(params.audioFormat);
  }

  /// Validates that the audio format supports streaming.
  /// 
  /// Not all audio formats are suitable for streaming. This method checks
  /// that the specified format can be streamed effectively.
  /// 
  /// ## Parameters
  /// 
  /// - [audioFormat]: The audio format to validate
  /// 
  /// ## Throws
  /// 
  /// - [ValidationException]: If the format doesn't support streaming
  void _validateStreamingAudioFormat(String audioFormat) {
    // List of formats that work well with streaming
    const streamingFormats = [
      'audio-16khz-32kbitrate-mono-mp3',
      'audio-16khz-64kbitrate-mono-mp3',
      'audio-16khz-128kbitrate-mono-mp3',
      'audio-24khz-48kbitrate-mono-mp3',
      'audio-24khz-96kbitrate-mono-mp3',
      'audio-24khz-160kbitrate-mono-mp3',
      'audio-48khz-96kbitrate-mono-mp3',
      'audio-48khz-192kbitrate-mono-mp3',
      'ogg-16khz-16bit-mono-opus',
      'ogg-24khz-16bit-mono-opus',
      'ogg-48khz-16bit-mono-opus',
      'webm-16khz-16bit-mono-opus',
      'webm-24khz-16bit-mono-opus',
    ];

    if (!streamingFormats.contains(audioFormat)) {
      throw ValidationException(
        'Audio format "$audioFormat" is not optimized for streaming. '
        'Consider using MP3 or Opus formats for better streaming performance.'
      );
    }
  }
}
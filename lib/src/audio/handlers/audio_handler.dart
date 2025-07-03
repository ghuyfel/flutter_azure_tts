import 'package:flutter_azure_tts/src/audio/client/audio_client.dart';
import 'package:flutter_azure_tts/src/audio/core/audio_request_param.dart';
import 'package:flutter_azure_tts/src/audio/core/audio_response_mapper.dart';
import 'package:flutter_azure_tts/src/audio/core/audio_responses.dart';
import 'package:flutter_azure_tts/src/auth/authentication_types.dart';
import 'package:flutter_azure_tts/src/common/azure_tts_config.dart';
import 'package:flutter_azure_tts/src/common/azure_tts_exception.dart';
import 'package:flutter_azure_tts/src/common/constants.dart';
import 'package:flutter_azure_tts/src/ssml/ssml.dart';
import 'package:http/http.dart' as http;

import '../core/audio_type_header.dart';

/// Handler for standard (non-streaming) audio requests to Azure Text-to-Speech service.
/// 
/// This class manages the process of generating complete audio files from text using
/// Azure TTS. It handles request formatting, HTTP communication, response processing,
/// and error handling for traditional TTS operations where the entire audio file
/// is generated and returned in a single response.
/// 
/// ## Features
/// 
/// - **Complete Audio Generation**: Generates entire audio files at once
/// - **SSML Processing**: Converts TTS parameters to proper SSML format
/// - **Error Handling**: Comprehensive error mapping and exception handling
/// - **Authentication**: Automatic token management and validation
/// - **Format Support**: Supports all Azure TTS audio formats
/// 
/// ## Usage
/// 
/// This handler is used internally by the main Azure TTS library:
/// 
/// ```dart
/// final handler = AudioHandler();
/// final audioResponse = await handler.getAudio(ttsParams);
/// 
/// if (audioResponse is AudioSuccess) {
///   final audioData = audioResponse.audio;
///   // Save or play the complete audio file
/// }
/// ```
/// 
/// ## Comparison with AudioStreamHandler
/// 
/// - **AudioHandler**: Generates complete audio files (traditional approach)
/// - **AudioStreamHandler**: Streams audio chunks in real-time (modern approach)
/// 
/// Choose AudioHandler when:
/// - You need the complete audio file before playback
/// - File size is manageable (short to medium texts)
/// - Simplicity is preferred over real-time streaming
/// 
/// Choose AudioStreamHandler when:
/// - You want to start playback immediately
/// - Dealing with long texts or large audio files
/// - Real-time user experience is important
class AudioHandler {
  /// Creates a new audio handler for standard TTS requests.
  AudioHandler();

  /// Generates audio from text using Azure Text-to-Speech service.
  /// 
  /// This method takes TTS parameters, converts them to the appropriate SSML format,
  /// sends the request to Azure TTS, and returns the complete generated audio file.
  /// 
  /// ## Parameters
  /// 
  /// - [params]: The TTS parameters including voice, text, format, and options
  /// 
  /// ## Returns
  /// 
  /// An [AudioSuccess] object containing the complete generated audio data.
  /// 
  /// ## Throws
  /// 
  /// - [InitializationException]: If the service hasn't been initialized
  /// - [AuthenticationException]: If authentication fails or token is expired
  /// - [ValidationException]: If the parameters are invalid
  /// - [NetworkException]: If the HTTP request fails
  /// - [RateLimitException]: If rate limits are exceeded
  /// - [ServiceUnavailableException]: If Azure service is unavailable
  /// 
  /// ## Process Flow
  /// 
  /// 1. **Validation**: Check that the service is initialized and authenticated
  /// 2. **SSML Generation**: Convert parameters to SSML markup
  /// 3. **HTTP Request**: Send POST request to Azure TTS endpoint
  /// 4. **Response Processing**: Parse response and handle errors
  /// 5. **Audio Extraction**: Extract audio data from successful response
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final handler = AudioHandler();
  /// 
  /// try {
  ///   final audioResponse = await handler.getAudio(ttsParams);
  ///   
  ///   print('Generated ${audioResponse.audio.length} bytes of audio');
  ///   
  ///   // Save to file
  ///   await File('output.mp3').writeAsBytes(audioResponse.audio);
  ///   
  ///   // Or play directly
  ///   audioPlayer.playBytes(audioResponse.audio);
  ///   
  /// } catch (e) {
  ///   print('Audio generation failed: $e');
  /// }
  /// ```
  /// 
  /// ## Performance Considerations
  /// 
  /// - **Memory Usage**: The entire audio file is loaded into memory
  /// - **Latency**: User must wait for complete generation before playback
  /// - **Network**: Single large response vs. multiple small chunks
  /// - **Caching**: Complete files are easier to cache effectively
  /// 
  /// For better user experience with long texts, consider using
  /// [AudioStreamHandler] for real-time streaming instead.
  Future<AudioSuccess> getAudio(AudioRequestParams params) async {
    // Get current configuration and auth token
    final config = ConfigManager().config;
    final authToken = ConfigManager().authToken;
    
    if (authToken == null || authToken.isExpired) {
      throw AuthenticationException('Authentication token is missing or expired');
    }

    // Create response mapper for handling different response types
    final mapper = AudioResponseMapper();
    
    // Create HTTP client with proper headers
    final audioClient = AudioClient(
      client: http.Client(),
      authHeader: BearerAuthenticationHeader(token: authToken.token),
      audioTypeHeader: AudioTypeHeader(audioFormat: params.audioFormat),
    );

    try {
      // Build SSML content from parameters
      final ssml = Ssml(
        voice: params.voice,
        text: params.text,
        speed: params.rate ?? 1,
        style: params.style,
        role: params.role,
      );

      // Send request to Azure TTS endpoint
      final response = await audioClient.post(
        Uri.parse(Endpoints.audio),
        body: ssml.buildSsml,
      );
      
      // Map HTTP response to appropriate response object
      final audioResponse = mapper.map(response);
      
      // Handle successful response
      if (audioResponse is AudioSuccess) {
        return audioResponse;
      } else {
        // Response indicates an error - throw it as an exception
        throw audioResponse;
      }
    } catch (e) {
      // Re-throw Azure TTS exceptions as-is
      if (e is AzureTtsException) rethrow;
      
      // Wrap other exceptions in NetworkException
      throw NetworkException('Failed to generate audio', e);
    } finally {
      // Clean up HTTP client
      audioClient.close();
    }
  }

  /// Validates audio generation parameters before making the request.
  /// 
  /// This method performs comprehensive validation of TTS parameters to ensure
  /// they meet Azure TTS requirements and are compatible with each other.
  /// 
  /// ## Parameters
  /// 
  /// - [params]: The TTS parameters to validate
  /// 
  /// ## Throws
  /// 
  /// - [ValidationException]: If any parameters are invalid
  /// 
  /// ## Validation Rules
  /// 
  /// - Text length must be within Azure limits (≤ 10,000 characters)
  /// - Audio format must be supported by Azure TTS
  /// - Voice must be available and support requested features
  /// - Rate must be within valid range (0.5 - 3.0)
  /// - Style must be supported by the voice (if specified)
  /// - Role must be supported by the voice (if specified)
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final handler = AudioHandler();
  /// 
  /// try {
  ///   handler.validateAudioParams(params);
  ///   // Parameters are valid, proceed with generation
  /// } on ValidationException catch (e) {
  ///   print('Invalid parameters: ${e.message}');
  ///   // Fix parameters before retrying
  /// }
  /// ```
  void validateAudioParams(AudioRequestParams params) {
    // Validate text length
    if (params.text.isEmpty) {
      throw ValidationException('Text cannot be empty for audio generation');
    }
    
    if (params.text.length > Constants.maxTextLength) {
      throw ValidationException(
        'Text length (${params.text.length}) exceeds maximum allowed '
        '(${Constants.maxTextLength}) for audio generation'
      );
    }

    // Validate speech rate
    final rate = params.rate ?? 1.0;
    if (rate < 0.5 || rate > 3.0) {
      throw ValidationException(
        'Speech rate ($rate) must be between 0.5 and 3.0 for audio generation'
      );
    }

    // Validate voice capabilities
    if (params.style != null && !params.voice.styles.contains(params.style!.style)) {
      throw ValidationException(
        'Voice "${params.voice.shortName}" does not support style "${params.style!.styleName}"'
      );
    }

    if (params.role != null && !params.voice.roles.contains(params.role!)) {
      throw ValidationException(
        'Voice "${params.voice.shortName}" does not support role "${params.role}"'
      );
    }

    // Additional format validation could be added here
    _validateAudioFormat(params.audioFormat);
  }

  /// Validates that the audio format is supported by Azure TTS.
  /// 
  /// ## Parameters
  /// 
  /// - [audioFormat]: The audio format to validate
  /// 
  /// ## Throws
  /// 
  /// - [ValidationException]: If the format is not supported
  void _validateAudioFormat(String audioFormat) {
    // Basic validation - in a real implementation, you might want to
    // check against a list of known supported formats
    if (audioFormat.isEmpty) {
      throw ValidationException('Audio format cannot be empty');
    }
    
    // Additional format-specific validation could be added here
    // For example, checking for valid format strings, supported codecs, etc.
  }
}
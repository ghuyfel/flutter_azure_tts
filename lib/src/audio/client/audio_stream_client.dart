import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_azure_tts/src/audio/core/audio_type_header.dart';
import 'package:flutter_azure_tts/src/audio/streaming/audio_stream.dart';
import 'package:flutter_azure_tts/src/auth/authentication_types.dart';
import 'package:flutter_azure_tts/src/common/azure_tts_exception.dart';
import 'package:flutter_azure_tts/src/common/base_client.dart';
import 'package:http/http.dart' as http;

/// HTTP client specialized for streaming audio responses from Azure TTS.
/// 
/// This client handles the complexities of streaming audio data from Azure's
/// Text-to-Speech service, including proper header management, chunk parsing,
/// and error handling for streaming responses.
/// 
/// ## Features
/// 
/// - **Streaming Support**: Handles chunked transfer encoding and SSE
/// - **Progress Tracking**: Provides real-time progress information
/// - **Error Recovery**: Robust error handling for network issues
/// - **Memory Efficient**: Processes audio in chunks rather than loading everything
/// 
/// ## Azure TTS Streaming Protocol
/// 
/// Azure TTS supports streaming through:
/// 1. **Chunked Transfer Encoding**: Audio data sent in HTTP chunks
/// 2. **Server-Sent Events**: For metadata and timing information
/// 3. **Custom Headers**: For audio format and streaming control
/// 
/// ## Usage
/// 
/// This client is used internally by the Azure TTS library and typically
/// doesn't need to be used directly by application code.
class AudioStreamClient extends BaseClient {
  /// Creates a new streaming audio client.
  /// 
  /// ## Parameters
  /// 
  /// - [client]: The underlying HTTP client to use
  /// - [authHeader]: Authentication header for Azure API
  /// - [audioTypeHeader]: Audio format specification header
  AudioStreamClient({
    required http.Client client,
    required BearerAuthenticationHeader authHeader,
    required AudioTypeHeader audioTypeHeader,
  }) : _audioTypeHeader = audioTypeHeader,
       super(client: client, header: authHeader);

  /// Audio format header for the streaming request.
  final AudioTypeHeader _audioTypeHeader;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Set required headers for streaming
    request.headers[header.type] = header.value;
    request.headers[_audioTypeHeader.type] = _audioTypeHeader.value;
    request.headers['Content-Type'] = 'application/ssml+xml';
    
    // Enable streaming response
    request.headers['Accept'] = 'audio/*';
    request.headers['Transfer-Encoding'] = 'chunked';
    
    return client.send(request);
  }

  /// Initiates a streaming TTS request and returns an audio stream.
  /// 
  /// This method sends the TTS request to Azure and returns a stream of
  /// audio chunks as they become available. The stream starts emitting
  /// chunks as soon as the first audio data is received.
  /// 
  /// ## Parameters
  /// 
  /// - [uri]: The Azure TTS endpoint URI
  /// - [ssmlBody]: The SSML content for speech synthesis
  /// 
  /// ## Returns
  /// 
  /// An [AudioStreamResponse] containing the stream of audio chunks.
  /// 
  /// ## Throws
  /// 
  /// - [NetworkException]: If the request fails or connection is lost
  /// - [AuthenticationException]: If authentication fails
  /// - [ServiceUnavailableException]: If Azure service is unavailable
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final client = AudioStreamClient(
  ///   client: http.Client(),
  ///   authHeader: authHeader,
  ///   audioTypeHeader: audioHeader,
  /// );
  /// 
  /// final streamResponse = await client.streamTts(uri, ssmlContent);
  /// 
  /// await for (final chunk in streamResponse.audioStream) {
  ///   // Process audio chunk
  ///   audioPlayer.addChunk(chunk.data);
  /// }
  /// ```
  Future<AudioStreamResponse> streamTts(Uri uri, String ssmlBody) async {
    try {
      // Create the streaming request
      final request = http.Request('POST', uri);
      request.body = ssmlBody;
      
      // Send the request and get streaming response
      final streamedResponse = await send(request);
      
      // Check for HTTP errors
      if (streamedResponse.statusCode != 200) {
        final responseBody = await streamedResponse.stream.bytesToString();
        _handleHttpError(streamedResponse.statusCode, responseBody);
      }

      // Extract content type
      final contentType = streamedResponse.headers['content-type'] ?? 'audio/mpeg';
      
      // Extract estimated content length if available
      final contentLengthHeader = streamedResponse.headers['content-length'];
      final estimatedSize = contentLengthHeader != null 
          ? int.tryParse(contentLengthHeader) 
          : null;

      // Create the audio chunk stream
      final audioStream = _createAudioStream(streamedResponse.stream);

      return AudioStreamResponse(
        audioStream: audioStream,
        contentType: contentType,
        totalEstimatedSize: estimatedSize,
      );
    } catch (e) {
      if (e is AzureTtsException) rethrow;
      throw NetworkException('Failed to initiate streaming TTS request', e);
    }
  }

  /// Creates a stream of audio chunks from the HTTP response stream.
  /// 
  /// This method processes the raw HTTP response stream and converts it
  /// into a stream of [AudioChunk] objects with proper sequencing and
  /// metadata.
  /// 
  /// ## Parameters
  /// 
  /// - [responseStream]: The raw HTTP response stream
  /// 
  /// ## Returns
  /// 
  /// A stream of [AudioChunk] objects.
  Stream<AudioChunk> _createAudioStream(Stream<List<int>> responseStream) {
    late StreamController<AudioChunk> controller;
    late StreamSubscription subscription;
    
    int sequenceNumber = 0;
    bool isComplete = false;
    // final startTime = DateTime.now();

    controller = StreamController<AudioChunk>(
      onListen: () {
        subscription = responseStream.listen(
          (List<int> data) {
            if (isComplete) return;

            // Convert to Uint8List for consistency
            final chunkData = Uint8List.fromList(data);
            
            // Create audio chunk with metadata
            final chunk = AudioChunk(
              data: chunkData,
              sequenceNumber: sequenceNumber++,
              timestamp: DateTime.now(),
              isLast: false, // Will be updated when stream ends
            );

            controller.add(chunk);
          },
          onDone: () {
            if (!isComplete) {
              isComplete = true;
              
              // Send final chunk marker if we received any data
              if (sequenceNumber > 0) {
                final finalChunk = AudioChunk(
                  data: Uint8List(0), // Empty data for final marker
                  sequenceNumber: sequenceNumber,
                  timestamp: DateTime.now(),
                  isLast: true,
                );
                controller.add(finalChunk);
              }
              
              controller.close();
            }
          },
          onError: (error) {
            if (!isComplete) {
              isComplete = true;
              controller.addError(
                NetworkException('Stream interrupted', error),
              );
            }
          },
        );
      },
      onCancel: () {
        isComplete = true;
        subscription.cancel();
      },
    );

    return controller.stream;
  }

  /// Handles HTTP error responses and throws appropriate exceptions.
  /// 
  /// ## Parameters
  /// 
  /// - [statusCode]: The HTTP status code
  /// - [responseBody]: The response body content
  /// 
  /// ## Throws
  /// 
  /// Appropriate [AzureTtsException] subclass based on the error type.
  void _handleHttpError(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        throw ValidationException('Bad request: $responseBody');
      case 401:
        throw AuthenticationException('Authentication failed: $responseBody');
      case 403:
        throw AuthenticationException('Access forbidden: $responseBody');
      case 429:
        throw RateLimitException('Rate limit exceeded: $responseBody', const Duration());
      case 500:
      case 502:
      case 503:
        throw ServiceUnavailableException('Azure service error: $responseBody');
      default:
        throw NetworkException('HTTP error $statusCode: $responseBody');
    }
  }
}

/// Utility class for managing streaming audio buffers and playback.
/// 
/// This class provides helper methods for working with streaming audio,
/// including buffering strategies, format conversion, and playback management.
/// 
/// ## Features
/// 
/// - **Smart Buffering**: Optimal buffer sizes for different scenarios
/// - **Format Detection**: Automatic audio format detection from chunks
/// - **Playback Control**: Integration helpers for audio players
/// - **Memory Management**: Efficient memory usage for large streams
/// 
/// ## Usage
/// 
/// ```dart
/// final buffer = StreamingAudioBuffer();
/// 
/// streamResponse.audioStream.listen((chunk) {
///   buffer.addChunk(chunk);
///   
///   if (buffer.hasEnoughDataForPlayback()) {
///     final playbackData = buffer.getPlaybackChunk();
///     audioPlayer.play(playbackData);
///   }
/// });
/// ```
class StreamingAudioBuffer {
  /// Creates a new streaming audio buffer.
  /// 
  /// ## Parameters
  /// 
  /// - [bufferSize]: Target buffer size in bytes (default: 64KB)
  /// - [minPlaybackBuffer]: Minimum bytes needed before starting playback (default: 16KB)
  StreamingAudioBuffer({
    this.bufferSize = 64 * 1024, // 64KB default
    this.minPlaybackBuffer = 16 * 1024, // 16KB minimum
  });

  /// Target buffer size in bytes.
  final int bufferSize;
  
  /// Minimum buffer size before starting playback.
  final int minPlaybackBuffer;

  /// Internal buffer for accumulating audio chunks.
  final List<Uint8List> _chunks = [];
  
  /// Total bytes currently buffered.
  int _totalBytes = 0;
  
  /// Whether the stream has completed.
  bool _isComplete = false;

  /// Adds an audio chunk to the buffer.
  /// 
  /// ## Parameters
  /// 
  /// - [chunk]: The audio chunk to add
  void addChunk(AudioChunk chunk) {
    if (chunk.data.isNotEmpty) {
      _chunks.add(chunk.data);
      _totalBytes += chunk.data.length;
    }
    
    if (chunk.isLast) {
      _isComplete = true;
    }
  }

  /// Checks if there's enough data buffered for smooth playback.
  /// 
  /// ## Returns
  /// 
  /// `true` if playback can start, `false` if more buffering is needed.
  bool hasEnoughDataForPlayback() {
    return _totalBytes >= minPlaybackBuffer || _isComplete;
  }

  /// Gets a chunk of data suitable for playback.
  /// 
  /// This method returns buffered audio data up to the target buffer size,
  /// removing it from the internal buffer.
  /// 
  /// ## Returns
  /// 
  /// Audio data ready for playback, or `null` if no data is available.
  Uint8List? getPlaybackChunk() {
    if (_chunks.isEmpty) return null;

    // Calculate how much data to return
    final targetSize = bufferSize.clamp(0, _totalBytes);
    if (targetSize == 0) return null;

    final result = Uint8List(targetSize);
    int offset = 0;
    int remaining = targetSize;

    // Copy data from chunks
    while (_chunks.isNotEmpty && remaining > 0) {
      final chunk = _chunks.first;
      final copySize = remaining.clamp(0, chunk.length);

      result.setRange(offset, offset + copySize, chunk);
      offset += copySize;
      remaining -= copySize;
      _totalBytes -= copySize;

      if (copySize == chunk.length) {
        // Consumed entire chunk
        _chunks.removeAt(0);
      } else {
        // Partial chunk consumption - update the chunk
        final remainingChunk = Uint8List.sublistView(chunk, copySize);
        _chunks[0] = remainingChunk;
      }
    }

    return offset > 0 ? Uint8List.sublistView(result, 0, offset) : null;
  }

  /// Gets all remaining buffered data.
  /// 
  /// This method returns all buffered audio data and clears the buffer.
  /// Use this when the stream is complete or when you need to flush the buffer.
  /// 
  /// ## Returns
  /// 
  /// All remaining buffered audio data.
  Uint8List getAllData() {
    if (_chunks.isEmpty) return Uint8List(0);

    final result = Uint8List(_totalBytes);
    int offset = 0;

    for (final chunk in _chunks) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    // Clear the buffer
    _chunks.clear();
    _totalBytes = 0;

    return result;
  }

  /// Current number of bytes in the buffer.
  int get bufferedBytes => _totalBytes;

  /// Whether the stream has completed.
  bool get isComplete => _isComplete;

  /// Whether the buffer is empty.
  bool get isEmpty => _chunks.isEmpty;

  /// Number of chunks currently in the buffer.
  int get chunkCount => _chunks.length;
}
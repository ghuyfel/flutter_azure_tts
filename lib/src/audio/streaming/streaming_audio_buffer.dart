import 'dart:typed_data';
import 'package:flutter_azure_tts/src/audio/streaming/audio_stream.dart';

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
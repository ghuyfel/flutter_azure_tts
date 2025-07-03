import 'package:flutter_azure_tts/src/tts/tts_params.dart';

/// Extended TTS parameters specifically for streaming audio requests.
/// 
/// This class extends the base [TtsParams] with additional configuration
/// options that are specific to streaming audio generation, such as
/// buffering preferences, chunk size hints, and streaming quality settings.
/// 
/// ## Streaming-Specific Features
/// 
/// - **Buffer Management**: Control over buffering behavior
/// - **Chunk Size Hints**: Optimization for different use cases
/// - **Quality vs Latency**: Trade-offs between audio quality and response time
/// - **Progress Tracking**: Enhanced progress reporting options
/// 
/// ## Usage
/// 
/// ```dart
/// final streamingParams = TtsStreamingParams(
///   voice: selectedVoice,
///   text: 'Hello, this is streaming audio!',
///   audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3,
///   rate: 1.0,
///   
///   // Streaming-specific options
///   preferredChunkSize: ChunkSize.small,
///   bufferStrategy: BufferStrategy.lowLatency,
///   enableProgressTracking: true,
/// );
/// ```
class TtsStreamingParams extends TtsParams {
  /// Creates streaming TTS parameters.
  /// 
  /// ## Parameters
  /// 
  /// All parameters from [TtsParams] plus streaming-specific options:
  /// 
  /// - [preferredChunkSize]: Hint for optimal chunk size
  /// - [bufferStrategy]: Buffering strategy for the stream
  /// - [enableProgressTracking]: Whether to provide detailed progress info
  /// - [maxLatency]: Maximum acceptable latency for first audio chunk
  const TtsStreamingParams({
    required super.voice,
    required super.audioFormat,
    required super.text,
    super.rate,
    super.style,
    super.role,
    this.preferredChunkSize = ChunkSize.medium,
    this.bufferStrategy = BufferStrategy.balanced,
    this.enableProgressTracking = true,
    this.maxLatency,
  });

  /// Preferred chunk size for streaming audio.
  /// 
  /// This is a hint to the streaming system about the optimal chunk size
  /// for your use case. Smaller chunks provide lower latency but may have
  /// more overhead, while larger chunks are more efficient but have higher latency.
  final ChunkSize preferredChunkSize;

  /// Buffering strategy for the audio stream.
  /// 
  /// This controls how the streaming system manages buffering:
  /// - [BufferStrategy.lowLatency]: Minimize latency, start playback quickly
  /// - [BufferStrategy.balanced]: Balance between latency and smooth playback
  /// - [BufferStrategy.highQuality]: Prioritize smooth playback over latency
  final BufferStrategy bufferStrategy;

  /// Whether to enable detailed progress tracking.
  /// 
  /// When enabled, the streaming response will include detailed progress
  /// information including throughput, timing, and completion estimates.
  /// This adds minimal overhead but provides valuable feedback for UI updates.
  final bool enableProgressTracking;

  /// Maximum acceptable latency for the first audio chunk.
  /// 
  /// If specified, the streaming system will optimize for getting the first
  /// chunk of audio within this time limit. This may affect overall quality
  /// or throughput for very aggressive latency requirements.
  final Duration? maxLatency;

  /// Creates a copy of these parameters with modified values.
  /// 
  /// ## Parameters
  /// 
  /// All parameters are optional. If not provided, the current value is retained.
  /// 
  /// ## Returns
  /// 
  /// A new [TtsStreamingParams] instance with the specified changes.
  TtsStreamingParams copyWith({
    // Base TtsParams fields
    voice,
    audioFormat,
    text,
    rate,
    style,
    role,
    
    // Streaming-specific fields
    ChunkSize? preferredChunkSize,
    BufferStrategy? bufferStrategy,
    bool? enableProgressTracking,
    Duration? maxLatency,
  }) {
    return TtsStreamingParams(
      voice: voice ?? this.voice,
      audioFormat: audioFormat ?? this.audioFormat,
      text: text ?? this.text,
      rate: rate ?? this.rate,
      style: style ?? this.style,
      role: role ?? this.role,
      preferredChunkSize: preferredChunkSize ?? this.preferredChunkSize,
      bufferStrategy: bufferStrategy ?? this.bufferStrategy,
      enableProgressTracking: enableProgressTracking ?? this.enableProgressTracking,
      maxLatency: maxLatency ?? this.maxLatency,
    );
  }

  @override
  String toString() {
    return 'TtsStreamingParams('
           'voice: ${voice.shortName}, '
           'text: ${text.length} chars, '
           'audioFormat: $audioFormat, '
           'rate: $rate, '
           'chunkSize: $preferredChunkSize, '
           'bufferStrategy: $bufferStrategy, '
           'progressTracking: $enableProgressTracking, '
           'maxLatency: $maxLatency'
           ')';
  }
}

/// Preferred chunk size for streaming audio.
/// 
/// This enum provides hints to the streaming system about the optimal
/// chunk size for different use cases. The actual chunk size may vary
/// based on network conditions and Azure service behavior.
/// 
/// ## Chunk Size Guidelines
/// 
/// - **Small (1-4KB)**: Best for real-time applications, voice chat
/// - **Medium (4-16KB)**: Good balance for most applications
/// - **Large (16-64KB)**: Best for high-quality playback, music
/// 
/// ## Trade-offs
/// 
/// - **Smaller chunks**: Lower latency, more network overhead
/// - **Larger chunks**: Higher latency, better efficiency
enum ChunkSize {
  /// Small chunks (1-4KB) for minimal latency.
  /// 
  /// Best for:
  /// - Real-time voice applications
  /// - Interactive voice responses
  /// - Live conversation systems
  /// 
  /// Trade-offs:
  /// - Lowest latency
  /// - Higher network overhead
  /// - May have more audio artifacts
  small,

  /// Medium chunks (4-16KB) for balanced performance.
  /// 
  /// Best for:
  /// - General text-to-speech applications
  /// - Reading applications
  /// - Most user interfaces
  /// 
  /// Trade-offs:
  /// - Good balance of latency and quality
  /// - Reasonable network efficiency
  /// - Suitable for most use cases
  medium,

  /// Large chunks (16-64KB) for high quality.
  /// 
  /// Best for:
  /// - High-quality audio playback
  /// - Long-form content
  /// - Background narration
  /// 
  /// Trade-offs:
  /// - Higher latency
  /// - Better audio quality
  /// - More efficient network usage
  large,
}

/// Buffering strategy for streaming audio.
/// 
/// This enum controls how the streaming system manages audio buffering
/// to balance between latency, quality, and smooth playback.
/// 
/// ## Strategy Comparison
/// 
/// | Strategy | Latency | Quality | Smoothness | Use Case |
/// |----------|---------|---------|------------|----------|
/// | Low Latency | Lowest | Good | Fair | Real-time |
/// | Balanced | Medium | Good | Good | General |
/// | High Quality | Higher | Best | Best | Playback |
enum BufferStrategy {
  /// Minimize latency, start playback as soon as possible.
  /// 
  /// This strategy prioritizes getting audio to the user as quickly as
  /// possible, even if it means occasional stuttering or lower quality.
  /// 
  /// **Characteristics:**
  /// - Starts playback with minimal buffering
  /// - May have occasional gaps or stutters
  /// - Best for interactive applications
  /// 
  /// **Best for:**
  /// - Voice assistants
  /// - Real-time communication
  /// - Interactive voice responses
  lowLatency,

  /// Balance between latency and smooth playback.
  /// 
  /// This strategy provides a good compromise between quick response
  /// and smooth audio playback, suitable for most applications.
  /// 
  /// **Characteristics:**
  /// - Moderate initial buffering
  /// - Good balance of responsiveness and quality
  /// - Handles most network conditions well
  /// 
  /// **Best for:**
  /// - General text-to-speech applications
  /// - Reading applications
  /// - User interface feedback
  balanced,

  /// Prioritize smooth playback and audio quality.
  /// 
  /// This strategy buffers more audio before starting playback to ensure
  /// smooth, high-quality audio without interruptions.
  /// 
  /// **Characteristics:**
  /// - Higher initial buffering
  /// - Smooth, uninterrupted playback
  /// - Best audio quality
  /// 
  /// **Best for:**
  /// - Long-form content
  /// - Audio books
  /// - High-quality narration
  highQuality,
}
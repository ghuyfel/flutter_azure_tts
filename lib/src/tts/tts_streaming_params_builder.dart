import 'package:flutter_azure_tts/src/tts/tts_params_builder.dart';
import 'package:flutter_azure_tts/src/tts/tts_streaming_params.dart';

/// Builder for creating [TtsStreamingParams] with comprehensive validation.
///
/// This class extends [TtsParamsBuilder] to provide additional configuration
/// options specific to streaming audio generation. It maintains the same
/// fluent interface while adding streaming-specific parameters and validation.
///
/// ## Features
///
/// - **Fluent Interface**: Method chaining for readable configuration
/// - **Streaming Validation**: Validates parameters for streaming compatibility
/// - **Performance Optimization**: Helps choose optimal settings for different use cases
/// - **Type Safety**: Compile-time checking of all parameters
///
/// ## Usage
///
/// ```dart
/// final streamingParams = TtsStreamingParamsBuilder()
///     .voice(selectedVoice)
///     .text('Hello, this is streaming audio!')
///     .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
///     .rate(1.2)
///     .preferredChunkSize(ChunkSize.small)
///     .bufferStrategy(BufferStrategy.lowLatency)
///     .enableProgressTracking(true)
///     .maxLatency(Duration(milliseconds: 500))
///     .build();
/// ```
///
/// ## Streaming Optimization
///
/// The builder helps optimize streaming parameters for different scenarios:
///
/// ```dart
/// // Real-time voice assistant
/// final realtimeParams = TtsStreamingParamsBuilder()
///     .voice(voice)
///     .text(userQuery)
///     .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
///     .preferredChunkSize(ChunkSize.small)
///     .bufferStrategy(BufferStrategy.lowLatency)
///     .maxLatency(Duration(milliseconds: 200))
///     .build();
///
/// // High-quality narration
/// final narrationParams = TtsStreamingParamsBuilder()
///     .voice(narratorVoice)
///     .text(longText)
///     .audioFormat(AudioOutputFormat.audio24khz96kBitrateMonoMp3)
///     .preferredChunkSize(ChunkSize.large)
///     .bufferStrategy(BufferStrategy.highQuality)
///     .build();
/// ```
class TtsStreamingParamsBuilder extends TtsParamsBuilder {
  /// Preferred chunk size for streaming.
  ChunkSize _preferredChunkSize = ChunkSize.medium;

  /// Buffer strategy for the stream.
  BufferStrategy _bufferStrategy = BufferStrategy.balanced;

  /// Whether to enable progress tracking.
  bool _enableProgressTracking = true;

  /// Maximum acceptable latency for first chunk.
  Duration? _maxLatency;

  /// Sets the preferred chunk size for streaming audio.
  ///
  /// The chunk size affects the trade-off between latency and efficiency:
  /// - [ChunkSize.small]: Lower latency, more overhead
  /// - [ChunkSize.medium]: Balanced performance (default)
  /// - [ChunkSize.large]: Higher latency, better efficiency
  ///
  /// ## Parameters
  ///
  /// - [chunkSize]: The preferred chunk size for streaming
  ///
  /// ## Returns
  ///
  /// This builder instance for method chaining.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // For real-time applications
  /// final builder = TtsStreamingParamsBuilder()
  ///     .preferredChunkSize(ChunkSize.small);
  ///
  /// // For high-quality playback
  /// final builder = TtsStreamingParamsBuilder()
  ///     .preferredChunkSize(ChunkSize.large);
  /// ```
  TtsStreamingParamsBuilder preferredChunkSize(ChunkSize chunkSize) {
    _preferredChunkSize = chunkSize;
    return this;
  }

  /// Sets the buffering strategy for the audio stream.
  ///
  /// The buffer strategy controls how audio is buffered before playback:
  /// - [BufferStrategy.lowLatency]: Start playback quickly, may have gaps
  /// - [BufferStrategy.balanced]: Good compromise (default)
  /// - [BufferStrategy.highQuality]: Smooth playback, higher initial delay
  ///
  /// ## Parameters
  ///
  /// - [strategy]: The buffering strategy to use
  ///
  /// ## Returns
  ///
  /// This builder instance for method chaining.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // For voice assistants
  /// final builder = TtsStreamingParamsBuilder()
  ///     .bufferStrategy(BufferStrategy.lowLatency);
  ///
  /// // For audio books
  /// final builder = TtsStreamingParamsBuilder()
  ///     .bufferStrategy(BufferStrategy.highQuality);
  /// ```
  TtsStreamingParamsBuilder bufferStrategy(BufferStrategy strategy) {
    _bufferStrategy = strategy;
    return this;
  }

  /// Enables or disables detailed progress tracking.
  ///
  /// When enabled, the streaming response will include detailed progress
  /// information such as bytes received, throughput, and completion estimates.
  /// This is useful for UI updates but adds minimal overhead.
  ///
  /// ## Parameters
  ///
  /// - [enabled]: Whether to enable progress tracking (default: true)
  ///
  /// ## Returns
  ///
  /// This builder instance for method chaining.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Enable progress tracking for UI updates
  /// final builder = TtsStreamingParamsBuilder()
  ///     .enableProgressTracking(true);
  ///
  /// // Disable for minimal overhead
  /// final builder = TtsStreamingParamsBuilder()
  ///     .enableProgressTracking(false);
  /// ```
  TtsStreamingParamsBuilder enableProgressTracking(bool enabled) {
    _enableProgressTracking = enabled;
    return this;
  }

  /// Sets the maximum acceptable latency for the first audio chunk.
  ///
  /// This parameter helps optimize the streaming system for your latency
  /// requirements. Setting a very low latency may affect audio quality
  /// or throughput.
  ///
  /// ## Parameters
  ///
  /// - [latency]: Maximum time to wait for the first audio chunk
  ///
  /// ## Returns
  ///
  /// This builder instance for method chaining.
  ///
  /// ## Throws
  ///
  /// - [ArgumentError]: If latency is negative or unreasonably small
  ///
  /// ## Example
  ///
  /// ```dart
  /// // For real-time applications
  /// final builder = TtsStreamingParamsBuilder()
  ///     .maxLatency(Duration(milliseconds: 200));
  ///
  /// // For less time-sensitive applications
  /// final builder = TtsStreamingParamsBuilder()
  ///     .maxLatency(Duration(seconds: 2));
  /// ```
  TtsStreamingParamsBuilder maxLatency(Duration latency) {
    if (latency.isNegative) {
      throw ArgumentError('Max latency cannot be negative');
    }
    if (latency.inMilliseconds < 50) {
      throw ArgumentError(
          'Max latency cannot be less than 50ms (current: ${latency.inMilliseconds}ms)');
    }
    _maxLatency = latency;
    return this;
  }

  /// Builds and validates the final [TtsStreamingParams] object.
  ///
  /// This method performs all the validation from the base [TtsParamsBuilder]
  /// plus additional validation specific to streaming parameters.
  ///
  /// ## Returns
  ///
  /// A validated [TtsStreamingParams] object ready for streaming TTS.
  ///
  /// ## Throws
  ///
  /// - [ArgumentError]: If required fields are missing or invalid
  /// - [ArgumentError]: If streaming-specific parameters are incompatible
  ///
  /// ## Validation Rules
  ///
  /// In addition to base TTS validation:
  /// - Audio format must support streaming
  /// - Chunk size and buffer strategy must be compatible
  /// - Max latency must be reasonable for the chosen settings
  ///
  /// ## Example
  ///
  /// ```dart
  /// try {
  ///   final streamingParams = TtsStreamingParamsBuilder()
  ///       .voice(selectedVoice)
  ///       .text('Hello world')
  ///       .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
  ///       .preferredChunkSize(ChunkSize.small)
  ///       .bufferStrategy(BufferStrategy.lowLatency)
  ///       .build();
  ///
  ///   // Use params for streaming TTS
  ///   final audioStream = await FlutterAzureTts.getTtsStream(streamingParams);
  /// } on ArgumentError catch (e) {
  ///   print('Invalid streaming parameters: ${e.message}');
  /// }
  /// ```
  @override
  TtsStreamingParams build() {
    // First, validate base TTS parameters
    final baseTtsParams = super.build();

    // Perform streaming-specific validation
    _validateStreamingCompatibility();

    // Create streaming parameters
    return TtsStreamingParams(
      voice: baseTtsParams.voice,
      audioFormat: baseTtsParams.audioFormat,
      text: baseTtsParams.text,
      rate: baseTtsParams.rate,
      style: baseTtsParams.style,
      role: baseTtsParams.role,
      preferredChunkSize: _preferredChunkSize,
      bufferStrategy: _bufferStrategy,
      enableProgressTracking: _enableProgressTracking,
      maxLatency: _maxLatency,
    );
  }

  /// Validates streaming-specific parameter combinations.
  ///
  /// This method checks that streaming parameters are compatible with
  /// each other and will work well together.
  ///
  /// ## Throws
  ///
  /// - [ArgumentError]: If parameter combinations are incompatible
  void _validateStreamingCompatibility() {
    // Validate chunk size and buffer strategy compatibility
    if (_preferredChunkSize == ChunkSize.large &&
        _bufferStrategy == BufferStrategy.lowLatency) {
      throw ArgumentError(
          'Large chunk size is incompatible with low latency buffer strategy. '
          'Consider using ChunkSize.small or ChunkSize.medium for low latency.');
    }

    // Validate max latency with buffer strategy
    final maxLatency = _maxLatency;
    if (maxLatency != null) {
      if (_bufferStrategy == BufferStrategy.highQuality &&
          maxLatency.inMilliseconds < 1000) {
        throw ArgumentError(
            'Max latency of ${maxLatency.inMilliseconds}ms is too aggressive for high quality buffer strategy. '
            'Consider using BufferStrategy.lowLatency or increasing max latency.');
      }

      if (_bufferStrategy == BufferStrategy.lowLatency &&
          maxLatency.inSeconds > 5) {
        throw ArgumentError(
            'Max latency of ${maxLatency.inSeconds}s is too high for low latency buffer strategy. '
            'Consider using BufferStrategy.balanced or BufferStrategy.highQuality.');
      }
    }

    // Validate chunk size with max latency
    if (_preferredChunkSize == ChunkSize.large &&
        maxLatency != null &&
        maxLatency.inMilliseconds < 500) {
      throw ArgumentError(
          'Large chunk size may not achieve max latency of ${maxLatency.inMilliseconds}ms. '
          'Consider using ChunkSize.small or ChunkSize.medium for low latency requirements.');
    }
  }

  /// Resets all streaming-specific parameters to defaults.
  ///
  /// This method resets both base TTS parameters and streaming-specific
  /// parameters, allowing the builder to be reused.
  ///
  /// ## Returns
  ///
  /// This builder instance for method chaining.
  @override
  TtsStreamingParamsBuilder reset() {
    super.reset();
    _preferredChunkSize = ChunkSize.medium;
    _bufferStrategy = BufferStrategy.balanced;
    _enableProgressTracking = true;
    _maxLatency = null;
    return this;
  }

  /// Creates a copy of this builder with the current state.
  ///
  /// This includes both base TTS parameters and streaming-specific parameters.
  ///
  /// ## Returns
  ///
  /// A new [TtsStreamingParamsBuilder] with the same state as this one.
  @override
  TtsStreamingParamsBuilder copy() {
    // Copy base parameters
    final newBuilder = super.copy() as TtsStreamingParamsBuilder;

    // Copy streaming parameters
    newBuilder._preferredChunkSize = _preferredChunkSize;
    newBuilder._bufferStrategy = _bufferStrategy;
    newBuilder._enableProgressTracking = _enableProgressTracking;
    newBuilder._maxLatency = _maxLatency;

    return newBuilder;
  }

  /// Creates optimized parameters for real-time voice applications.
  ///
  /// This factory method creates a builder pre-configured for real-time
  /// applications like voice assistants or interactive voice responses.
  ///
  /// ## Returns
  ///
  /// A [TtsStreamingParamsBuilder] optimized for real-time use.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final realtimeParams = TtsStreamingParamsBuilder.forRealtime()
  ///     .voice(assistantVoice)
  ///     .text(userQuery)
  ///     .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
  ///     .build();
  /// ```
  factory TtsStreamingParamsBuilder.forRealtime() {
    return TtsStreamingParamsBuilder()
        .preferredChunkSize(ChunkSize.small)
        .bufferStrategy(BufferStrategy.lowLatency)
        .enableProgressTracking(true)
        .maxLatency(Duration(milliseconds: 300));
  }

  /// Creates optimized parameters for high-quality audio playback.
  ///
  /// This factory method creates a builder pre-configured for high-quality
  /// audio applications like audiobooks or narration.
  ///
  /// ## Returns
  ///
  /// A [TtsStreamingParamsBuilder] optimized for high-quality playback.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final qualityParams = TtsStreamingParamsBuilder.forHighQuality()
  ///     .voice(narratorVoice)
  ///     .text(bookChapter)
  ///     .audioFormat(AudioOutputFormat.audio24khz96kBitrateMonoMp3)
  ///     .build();
  /// ```
  factory TtsStreamingParamsBuilder.forHighQuality() {
    return TtsStreamingParamsBuilder()
        .preferredChunkSize(ChunkSize.large)
        .bufferStrategy(BufferStrategy.highQuality)
        .enableProgressTracking(true);
  }

  /// Creates balanced parameters suitable for most applications.
  ///
  /// This factory method creates a builder with balanced settings that
  /// work well for most general-purpose text-to-speech applications.
  ///
  /// ## Returns
  ///
  /// A [TtsStreamingParamsBuilder] with balanced settings.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final balancedParams = TtsStreamingParamsBuilder.balanced()
  ///     .voice(generalVoice)
  ///     .text(articleText)
  ///     .audioFormat(AudioOutputFormat.audio16khz64kBitrateMonoMp3)
  ///     .build();
  /// ```
  factory TtsStreamingParamsBuilder.balanced() {
    return TtsStreamingParamsBuilder()
        .preferredChunkSize(ChunkSize.medium)
        .bufferStrategy(BufferStrategy.balanced)
        .enableProgressTracking(true);
  }

  @override
  String toString() {
    final ttsParams = super.build();
    return 'TtsStreamingParamsBuilder('
        'voice: ${ttsParams.voice.shortName}, '
        'text: ${ttsParams.text.length} chars, '
        'audioFormat: ${ttsParams.audioFormat}, '
        'rate: ${ttsParams.rate}, '
        'chunkSize: $_preferredChunkSize, '
        'bufferStrategy: $_bufferStrategy, '
        'progressTracking: $_enableProgressTracking, '
        'maxLatency: $_maxLatency'
        ')';
  }

  TtsStreamingParamsBuilder();
}

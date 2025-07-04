import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:flutter_azure_tts/src/audio/client/audio_stream_client.dart';

const _azureKey = 'YOUR SUBSCRIPTION KEY';
const _azureRegion = 'YOUR REGION';

void main() async {
  try {
    // Initialize Azure TTS
    FlutterAzureTts.init(
      subscriptionKey: _azureKey,
      region: _azureRegion,
      withLogs: true,
    );

    // Get available voices
    final voicesResponse = await FlutterAzureTts.getAvailableVoices();
    
    // Find a suitable voice for streaming
    final voice = voicesResponse.voices
        .filter()
        .byLocale('en-US')
        .neural()
        .firstOrThrow;

    print('Using voice: ${voice.displayName} (${voice.shortName})');

    // Example 1: Basic streaming
    await _basicStreamingExample(voice);
    
    // Example 2: Real-time streaming with low latency
    await _realtimeStreamingExample(voice);
    
    // Example 3: High-quality streaming
    await _highQualityStreamingExample(voice);
    
    // Example 4: Streaming with progress tracking
    await _streamingWithProgressExample(voice);
    
    print('All streaming examples completed!');
    
  } on InitializationException catch (e) {
    print('Initialization failed: $e');
  } on NetworkException catch (e) {
    print('Network error: $e');
  } on AzureTtsException catch (e) {
    print('Azure TTS error: $e');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

/// Basic streaming example - demonstrates simple streaming TTS
Future<void> _basicStreamingExample(Voice voice) async {
  print('\n=== Basic Streaming Example ===');
  
  final params = TtsStreamingParamsBuilder()
      .voice(voice)
      .text('This is a basic streaming example. The audio will be delivered in real-time chunks.')
      .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
      .build() as TtsStreamingParams;

  final streamResponse = await FlutterAzureTts.getTtsStream(params);
  final audioBuffer = <Uint8List>[];
  
  print('Starting basic streaming...');
  
  await for (final chunk in streamResponse.audioStream) {
    print('Received chunk ${chunk.sequenceNumber}: ${chunk.size} bytes at ${chunk.timestamp}');
    audioBuffer.add(chunk.data);
    
    if (chunk.isLast) {
      print('Basic streaming completed');
      break;
    }
  }
  
  // Save the complete audio
  await _saveAudioBuffer(audioBuffer, 'basic_streaming.mp3');
}

/// Real-time streaming example - optimized for low latency
Future<void> _realtimeStreamingExample(Voice voice) async {
  print('\n=== Real-time Streaming Example ===');
  
  final params = TtsStreamingParamsBuilder.forRealtime()
      .maxLatency(Duration(milliseconds: 200))
      .voice(voice)
      .text('This is optimized for real-time playback with minimal latency!')
      .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
      .build() as TtsStreamingParams;

  final streamResponse = await FlutterAzureTts.getTtsStream(params);
  final buffer = StreamingAudioBuffer(
    bufferSize: 8 * 1024,  // 8KB chunks for low latency
    minPlaybackBuffer: 2 * 1024,  // Start playback with just 2KB
  );
  
  print('Starting real-time streaming (low latency)...');
  
  await for (final chunk in streamResponse.audioStream) {
    buffer.addChunk(chunk);
    
    // Simulate real-time playback
    if (buffer.hasEnoughDataForPlayback()) {
      final playbackChunk = buffer.getPlaybackChunk();
      if (playbackChunk != null) {
        print('Playing chunk: ${playbackChunk.length} bytes (buffered: ${buffer.bufferedBytes})');
        // In a real app, you would send this to an audio player
      }
    }
    
    if (chunk.isLast) {
      // Play any remaining buffered audio
      final remainingAudio = buffer.getAllData();
      if (remainingAudio.isNotEmpty) {
        print('Playing final chunk: ${remainingAudio.length} bytes');
      }
      print('Real-time streaming completed');
      break;
    }
  }
}

/// High-quality streaming example - optimized for audio quality
Future<void> _highQualityStreamingExample(Voice voice) async {
  print('\n=== High-Quality Streaming Example ===');
  
  final params = TtsStreamingParamsBuilder.forHighQuality()
      .voice(voice)
      .text('This example demonstrates high-quality streaming with larger buffers for smooth playback.')
      .audioFormat(AudioOutputFormat.audio24khz96kBitrateMonoMp3)
      .build() as TtsStreamingParams;

  final streamResponse = await FlutterAzureTts.getTtsStream(params);
  final buffer = StreamingAudioBuffer(
    bufferSize: 64 * 1024,  // 64KB chunks for quality
    minPlaybackBuffer: 32 * 1024,  // Wait for 32KB before starting
  );
  
  print('Starting high-quality streaming...');
  
  await for (final chunk in streamResponse.audioStream) {
    buffer.addChunk(chunk);
    
    if (buffer.hasEnoughDataForPlayback()) {
      final playbackChunk = buffer.getPlaybackChunk();
      if (playbackChunk != null) {
        print('High-quality playback: ${playbackChunk.length} bytes');
      }
    }
    
    if (chunk.isLast) {
      final remainingAudio = buffer.getAllData();
      if (remainingAudio.isNotEmpty) {
        print('Final high-quality chunk: ${remainingAudio.length} bytes');
      }
      print('High-quality streaming completed');
      break;
    }
  }
}

/// Streaming with progress tracking example
Future<void> _streamingWithProgressExample(Voice voice) async {
  print('\n=== Streaming with Progress Tracking Example ===');
  
  final params = TtsStreamingParamsBuilder.balanced()
      .enableProgressTracking(true)
      .voice(voice)
      .text('This example shows how to track progress during streaming. '
             'You can see real-time statistics about the streaming process including '
             'bytes received, throughput, and completion percentage.')
      .audioFormat(AudioOutputFormat.audio16khz64kBitrateMonoMp3)

      .build() as TtsStreamingParams;

  final (streamResponse, progressStream) = await FlutterAzureTts.getTtsStreamWithProgress(params);
  final audioBuffer = <Uint8List>[];
  
  print('Starting streaming with progress tracking...');
  
  // Listen to progress updates
  progressStream.listen((progress) {
    final percent = progress.percentComplete;
    final percentStr = percent != null ? '${(percent * 100).toStringAsFixed(1)}%' : 'unknown';
    
    print('Progress: $percentStr | '
          'Speed: ${progress.bytesPerSecond.toStringAsFixed(1)} B/s | '
          'Chunks: ${progress.chunksReceived} | '
          'Elapsed: ${progress.elapsedTime.inMilliseconds}ms');
  });
  
  // Process audio chunks
  await for (final chunk in streamResponse.audioStream) {
    audioBuffer.add(chunk.data);
    
    if (chunk.isLast) {
      print('Streaming with progress tracking completed');
      break;
    }
  }
  
  // Save the complete audio
  await _saveAudioBuffer(audioBuffer, 'progress_streaming.mp3');
}

/// Helper function to save audio buffer to file
Future<void> _saveAudioBuffer(List<Uint8List> audioBuffer, String filename) async {
  if (audioBuffer.isEmpty) return;
  
  // Calculate total size
  final totalSize = audioBuffer.fold<int>(0, (sum, chunk) => sum + chunk.length);
  
  // Combine all chunks
  final completeAudio = Uint8List(totalSize);
  int offset = 0;
  
  for (final chunk in audioBuffer) {
    completeAudio.setRange(offset, offset + chunk.length, chunk);
    offset += chunk.length;
  }
  
  // Save to file
  final file = File(filename);
  await file.writeAsBytes(completeAudio);
  print('Saved ${(totalSize / 1024).toStringAsFixed(2)}KB to $filename');
}
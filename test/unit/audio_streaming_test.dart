import 'package:flutter_azure_tts/src/audio/audio_stream.dart';
import 'package:flutter_azure_tts/src/tts/tts_streaming_params.dart';
import 'package:flutter_azure_tts/src/tts/tts_streaming_params_builder.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

void main() {
  group('Audio Streaming', () {
    late Voice testVoice;

    setUp(() {
      testVoice = Voice(
        name: 'Test Voice',
        displayName: 'Test',
        localName: 'Test',
        shortName: 'en-US-TestNeural',
        gender: 'Female',
        locale: 'en-US',
        sampleRateHertz: '24000',
        voiceType: 'Neural',
        status: 'GA',
        styles: [VoiceStyle.cheerful],
        roles: [VoiceRole.YoungAdultFemale],
      );
    });

    group('AudioChunk', () {
      test('should create audio chunk with metadata', () {
        final data = Uint8List.fromList([1, 2, 3, 4]);
        final timestamp = DateTime.now();
        
        final chunk = AudioChunk(
          data: data,
          sequenceNumber: 0,
          timestamp: timestamp,
          isLast: false,
        );

        expect(chunk.data, equals(data));
        expect(chunk.sequenceNumber, equals(0));
        expect(chunk.timestamp, equals(timestamp));
        expect(chunk.isLast, isFalse);
        expect(chunk.size, equals(4));
      });

      test('should identify last chunk', () {
        final chunk = AudioChunk(
          data: Uint8List(0),
          sequenceNumber: 5,
          timestamp: DateTime.now(),
          isLast: true,
        );

        expect(chunk.isLast, isTrue);
      });
    });

    group('TtsStreamingParams', () {
      test('should create with default streaming options', () {
        final params = TtsStreamingParams(
          voice: testVoice,
          text: 'Test text',
          audioFormat: 'audio-16khz-32kbitrate-mono-mp3',
        );

        expect(params.preferredChunkSize, equals(ChunkSize.medium));
        expect(params.bufferStrategy, equals(BufferStrategy.balanced));
        expect(params.enableProgressTracking, isTrue);
        expect(params.maxLatency, isNull);
      });

      test('should create with custom streaming options', () {
        final maxLatency = Duration(milliseconds: 500);
        
        final params = TtsStreamingParams(
          voice: testVoice,
          text: 'Test text',
          audioFormat: 'audio-16khz-32kbitrate-mono-mp3',
          preferredChunkSize: ChunkSize.small,
          bufferStrategy: BufferStrategy.lowLatency,
          enableProgressTracking: false,
          maxLatency: maxLatency,
        );

        expect(params.preferredChunkSize, equals(ChunkSize.small));
        expect(params.bufferStrategy, equals(BufferStrategy.lowLatency));
        expect(params.enableProgressTracking, isFalse);
        expect(params.maxLatency, equals(maxLatency));
      });
    });

    group('TtsStreamingParamsBuilder', () {
      test('should build valid streaming params', () {
        final params = TtsStreamingParamsBuilder()
            .voice(testVoice)
            .text('Hello streaming world')
            .audioFormat('audio-16khz-32kbitrate-mono-mp3')
            .preferredChunkSize(ChunkSize.small)
            .bufferStrategy(BufferStrategy.lowLatency)
            .enableProgressTracking(true)
            .maxLatency(Duration(milliseconds: 300))
            .build();

        expect(params.voice, equals(testVoice));
        expect(params.text, equals('Hello streaming world'));
        expect(params.preferredChunkSize, equals(ChunkSize.small));
        expect(params.bufferStrategy, equals(BufferStrategy.lowLatency));
        expect(params.enableProgressTracking, isTrue);
        expect(params.maxLatency, equals(Duration(milliseconds: 300)));
      });

      test('should throw on invalid max latency', () {
        expect(
          () => TtsStreamingParamsBuilder().maxLatency(Duration(milliseconds: 10)),
          throwsArgumentError,
        );
        
        expect(
          () => TtsStreamingParamsBuilder().maxLatency(Duration(milliseconds: -100)),
          throwsArgumentError,
        );
      });

      test('should validate incompatible chunk size and buffer strategy', () {
        expect(
          () => TtsStreamingParamsBuilder()
              .voice(testVoice)
              .text('Test')
              .audioFormat('audio-16khz-32kbitrate-mono-mp3')
              .preferredChunkSize(ChunkSize.large)
              .bufferStrategy(BufferStrategy.lowLatency)
              .build(),
          throwsArgumentError,
        );
      });

      test('should create realtime optimized params', () {
        final params = TtsStreamingParamsBuilder.forRealtime()
            .voice(testVoice)
            .text('Realtime test')
            .audioFormat('audio-16khz-32kbitrate-mono-mp3')
            .build();

        expect(params.preferredChunkSize, equals(ChunkSize.small));
        expect(params.bufferStrategy, equals(BufferStrategy.lowLatency));
        expect(params.maxLatency, equals(Duration(milliseconds: 300)));
      });

      test('should create high quality optimized params', () {
        final params = TtsStreamingParamsBuilder.forHighQuality()
            .voice(testVoice)
            .text('Quality test')
            .audioFormat('audio-24khz-96kbitrate-mono-mp3')
            .build();

        expect(params.preferredChunkSize, equals(ChunkSize.large));
        expect(params.bufferStrategy, equals(BufferStrategy.highQuality));
      });
    });

    group('StreamProgress', () {
      test('should calculate progress percentage', () {
        final progress = StreamProgress(
          bytesReceived: 500,
          totalEstimatedBytes: 1000,
          chunksReceived: 5,
          elapsedTime: Duration(seconds: 1),
          isComplete: false,
        );

        expect(progress.percentComplete, equals(0.5));
        expect(progress.bytesPerSecond, equals(500.0));
        expect(progress.chunksPerSecond, equals(5.0));
      });

      test('should handle unknown total size', () {
        final progress = StreamProgress(
          bytesReceived: 500,
          totalEstimatedBytes: null,
          chunksReceived: 5,
          elapsedTime: Duration(seconds: 1),
          isComplete: false,
        );

        expect(progress.percentComplete, isNull);
        expect(progress.bytesPerSecond, equals(500.0));
      });
    });

    group('StreamingAudioBuffer', () {
      test('should buffer audio chunks', () {
        final buffer = StreamingAudioBuffer();
        final chunk1 = AudioChunk(
          data: Uint8List.fromList([1, 2, 3]),
          sequenceNumber: 0,
          timestamp: DateTime.now(),
        );
        final chunk2 = AudioChunk(
          data: Uint8List.fromList([4, 5, 6]),
          sequenceNumber: 1,
          timestamp: DateTime.now(),
        );

        buffer.addChunk(chunk1);
        buffer.addChunk(chunk2);

        expect(buffer.bufferedBytes, equals(6));
        expect(buffer.chunkCount, equals(2));
        expect(buffer.isEmpty, isFalse);
      });

      test('should determine when enough data for playback', () {
        final buffer = StreamingAudioBuffer(minPlaybackBuffer: 10);
        
        expect(buffer.hasEnoughDataForPlayback(), isFalse);
        
        final chunk = AudioChunk(
          data: Uint8List(15),
          sequenceNumber: 0,
          timestamp: DateTime.now(),
        );
        buffer.addChunk(chunk);
        
        expect(buffer.hasEnoughDataForPlayback(), isTrue);
      });

      test('should get playback chunks', () {
        final buffer = StreamingAudioBuffer(bufferSize: 10);
        final chunk = AudioChunk(
          data: Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]),
          sequenceNumber: 0,
          timestamp: DateTime.now(),
        );
        
        buffer.addChunk(chunk);
        
        final playbackChunk = buffer.getPlaybackChunk();
        expect(playbackChunk?.length, equals(10));
        expect(buffer.bufferedBytes, equals(2)); // Remaining bytes
      });
    });
  });
}
import 'package:flutter_azure_tts/src/audio/audio_output_format.dart';
import 'package:flutter_azure_tts/src/tts/tts_params_builder.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';
import 'package:test/test.dart';

void main() {
  group('TtsParamsBuilder', () {
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

    test('should build valid TtsParams', () {
      final params = TtsParamsBuilder()
          .voice(testVoice)
          .text('Hello world')
          .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
          .rate(1.0)
          .build();

      expect(params.voice, equals(testVoice));
      expect(params.text, equals('Hello world'));
      expect(params.rate, equals(1.0));
    });

    test('should throw when text is empty', () {
      expect(
        () => TtsParamsBuilder().text(''),
        throwsArgumentError,
      );
    });

    test('should throw when text is too long', () {
      final longText = 'a' * 10001;
      expect(
        () => TtsParamsBuilder().text(longText),
        throwsArgumentError,
      );
    });

    test('should throw when rate is out of range', () {
      expect(
        () => TtsParamsBuilder().rate(0.1),
        throwsArgumentError,
      );
      expect(
        () => TtsParamsBuilder().rate(4.0),
        throwsArgumentError,
      );
    });

    test('should throw when required fields are missing', () {
      expect(
        () => TtsParamsBuilder().build(),
        throwsArgumentError,
      );
    });
  });
}
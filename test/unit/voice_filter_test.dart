import 'package:flutter_azure_tts/src/voices/voices.dart';
import 'package:flutter_azure_tts/src/voices/voice_filter.dart';
import 'package:test/test.dart';

void main() {
  group('VoiceFilter', () {
    late List<Voice> testVoices;

    setUp(() {
      testVoices = [
        Voice(
          name: 'Microsoft Server Speech Text to Speech Voice (en-US, JennyNeural)',
          displayName: 'Jenny',
          localName: 'Jenny',
          shortName: 'en-US-JennyNeural',
          gender: 'Female',
          locale: 'en-US',
          sampleRateHertz: '24000',
          voiceType: 'Neural',
          status: 'GA',
          styles: [VoiceStyle.cheerful, VoiceStyle.sad],
          roles: [VoiceRole.YoungAdultFemale],
        ),
        Voice(
          name: 'Microsoft Server Speech Text to Speech Voice (en-GB, RyanNeural)',
          displayName: 'Ryan',
          localName: 'Ryan',
          shortName: 'en-GB-RyanNeural',
          gender: 'Male',
          locale: 'en-GB',
          sampleRateHertz: '24000',
          voiceType: 'Neural',
          status: 'GA',
          styles: [],
          roles: [],
        ),
      ];
    });

    test('should filter by locale', () {
      final filtered = testVoices.filter().byLocale('en-US').results;
      expect(filtered.length, equals(1));
      expect(filtered.first.shortName, equals('en-US-JennyNeural'));
    });

    test('should filter by gender', () {
      final filtered = testVoices.filter().byGender('Male').results;
      expect(filtered.length, equals(1));
      expect(filtered.first.shortName, equals('en-GB-RyanNeural'));
    });

    test('should filter voices with styles', () {
      final filtered = testVoices.filter().withStyles().results;
      expect(filtered.length, equals(1));
      expect(filtered.first.shortName, equals('en-US-JennyNeural'));
    });

    test('should chain filters', () {
      final filtered = testVoices.filter()
          .byLocale('en-')
          .byGender('Female')
          .withStyles()
          .results;
      expect(filtered.length, equals(1));
      expect(filtered.first.shortName, equals('en-US-JennyNeural'));
    });

    test('should return empty list when no matches', () {
      final filtered = testVoices.filter().byLocale('fr-').results;
      expect(filtered.isEmpty, isTrue);
    });

    test('should throw when calling firstOrThrow on empty results', () {
      expect(
        () => testVoices.filter().byLocale('fr-').firstOrThrow,
        throwsStateError,
      );
    });
  });
}
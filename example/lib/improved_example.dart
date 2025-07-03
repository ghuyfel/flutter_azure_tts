import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_azure_tts/flutter_azure_tts.dart';

const _azureKey = 'YOUR SUBSCRIPTION KEY';
const _azureRegion = 'YOUR REGION';

void main() async {
  try {
    // Initialize with improved configuration
    FlutterAzureTts.init(
      subscriptionKey: _azureKey,
      region: _azureRegion,
      withLogs: true,
      retryPolicy: const RetryPolicy(
        maxRetries: 3,
        baseDelay: Duration(milliseconds: 500),
      ),
      requestTimeout: const Duration(seconds: 30),
    );

    // Get available voices using the new filter API
    final voicesResponse = await FlutterAzureTts.getAvailableVoices();
    
    // Use the improved voice filtering
    final voice = voicesResponse.voices
        .filter()
        .byLocale('en-US')
        .neural()
        .withStyles()
        .firstOrThrow;

    print('Selected voice: ${voice.displayName} (${voice.shortName})');
    print('Available styles: ${voice.styles.map((s) => s.styleName).join(', ')}');

    // Use the builder pattern for TTS parameters
    final params = TtsParamsBuilder()
        .voice(voice)
        .text('Hello! This is an example of the improved Azure TTS package.')
        .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
        .rate(1.0)
        .style(StyleSsml(style: VoiceStyle.cheerful, styleDegree: 1.2))
        .build();

    // Generate audio
    final ttsResponse = await FlutterAzureTts.getTts(params);
    
    // Save to file
    await _saveAudioFile('improved_example.mp3', ttsResponse.audio);
    
    print('Audio generated successfully!');
    
  } on InitializationException catch (e) {
    print('Initialization failed: $e');
  } on ValidationException catch (e) {
    print('Validation error: $e');
  } on NetworkException catch (e) {
    print('Network error: $e');
  } on AzureTtsException catch (e) {
    print('Azure TTS error: $e');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

Future<void> _saveAudioFile(String filename, Uint8List data) async {
  final file = File(filename);
  await file.writeAsBytes(data);
  print('Saved ${(data.lengthInBytes / 1024).toStringAsFixed(2)}KB to $filename');
}
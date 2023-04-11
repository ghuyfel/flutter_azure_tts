import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:flutter_azure_tts/src/audio/audio_output_format.dart';
import 'package:flutter_azure_tts/src/tts/tts_params.dart';

void main() async {
  try {
    //Load configs
    AzureTts.init(
        subscriptionKey: "YOUR SUBSCRIPTION KEY",
        region: "YOUR REGION",
        withLogs: true);

    // Get available voices
    final voicesResponse = await AzureTts.getAvailableVoices();
    final voices = voicesResponse.voices;

    //Print all available voices
    print("$voices");

    //Pick an English Neural Voice
    final voice = voicesResponse.voices
        .where((element) => element.locale.startsWith("en-"))
        .toList(growable: false)
        .first;

    //Generate Audio for a text
    final text = "Microsoft Speech Service Text-to-Speech API is awesome";

    TtsParams params = TtsParams(
        voice: voice,
        audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3,
        rate: 1.5, // optional prosody rate (default is 1.0)
        text: text);

    final ttsResponse = await AzureTts.getTts(params);

    //Get the audio bytes.
    final audioBytes = ttsResponse.audio.buffer
        .asByteData(); // you can save to a file for playback
    print(
        "Audio size: ${(audioBytes.lengthInBytes / (1024 * 1024)).toStringAsPrecision(2)} Mb");
  } catch (e) {
    print("Something went wrong: $e");
  }
}

import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:flutter_azure_tts/src/ssml/style_ssml.dart';

void main() async {
  try {
    //Load configs
    FlutterAzureTts.init(
      subscriptionKey: "YOUR SUBSCRIPTION KEY",
      region: "YOUR REGION",
      withLogs: true,
    );

    // Get available voices
    final voicesResponse = await FlutterAzureTts.getAvailableVoices();
    final voices = voicesResponse.voices;

    //Print all available voices
    print("$voices");

    //Pick an English Neural Voice that supports styles and roles
    final voice = voicesResponse.voices
        .where((element) =>
            element.locale.startsWith("en-") &&
            element.roles.isNotEmpty &&
            element.styles.isNotEmpty)
        .toList(growable: false)
        .first;

    //Generate Audio for a text
    final text = "Microsoft Speech Service Text-to-Speech API is awesome";

    TtsParams params = TtsParams(
        voice: voice,
        audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3,
        rate: 1.5,
        // optional prosody rate (default is 1.0)
        style: StyleSsml(style: voice.styles.first, styleDegree: 1.5),
        // optional speech style, degree defaults to 1 (not supported by all voices)
        role: VoiceRole.OlderAdultMale,
        // optional imitates a certain person's pitch (not supported by all voices)
        text: text);

    final ttsResponse = await FlutterAzureTts.getTts(params);

    //Get the audio bytes.
    final audioBytes = ttsResponse.audio.buffer
        .asByteData(); // you can save to a file for playback
    print(
        "Audio size: ${(audioBytes.lengthInBytes / (1024 * 1024)).toStringAsPrecision(2)} Mb");
  } catch (e) {
    print("Something went wrong: $e");
  }
}

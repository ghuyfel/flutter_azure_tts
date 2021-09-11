import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:flutter_azure_tts/src/audio/audio_output_format.dart';
import 'package:flutter_azure_tts/src/tts/tts_params.dart';

void main() async {
  AzureTts.init(
      subscriptionKey: "YOUR SUBSCRIPTION KEY",
      region: "YOUR REGION",
      withLogs: true);

  // Get available voices
  final voicesResponse = await AzureTts.getAvailableVoices() as VoicesSuccess;

  //Pick a Neural voice
  final voice = voicesResponse.voices
      .where((element) =>
          element.voiceType == "Neural" && element.locale.startsWith("en-"))
      .toList(growable: false)[0];

  //List all available voices
  print("${voicesResponse.voices}");

  final text = "Microsoft Speech Service Text-to-Speech API";

  TtsParams params = TtsParams(
      voice: voice,
      audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3,
      text: text);
  final ttsResponse = await AzureTts.getTts(params) as AudioSuccess;

  //Get the audio bytes.
  print("${ttsResponse.audio}");
}

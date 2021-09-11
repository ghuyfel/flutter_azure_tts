# flutter_azure_tts

Flutter implementation of [Microsoft Azure Cognitive Text-To-Speech API](https://azure.microsoft.com/en-us/services/cognitive-services/text-to-speech/#features).

## Getting Started

Initialise the framework with your Region and Subscription key

```dart
  AzureTts.init(
      subscriptionKey: "YOUR SUBSCRIPTION KEY",
      region: "YOUR REGION",
      withLogs: true); // enable logs
```

Get the list of all available voices. And pick a voice to read the text.

```dart
// Get available voices
  final voicesResponse = await AzureTts.getAvailableVoices() as VoicesSuccess;
  
  //Pick a Neural voice
  final voice = voicesResponse.voices.where((element) =>
          element.voiceType == "Neural" && element.locale.startsWith("en-"))
      .toList(growable: false)[0];
```

Request audio file.

```dart
  final text = "Microsoft Speech Service Text-to-Speech API";

  TtsParams params = TtsParams(voice: voice, audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3, text: text);
  
  final ttsResponse = await AzureTts.getTts(params) as AudioSuccess;
```

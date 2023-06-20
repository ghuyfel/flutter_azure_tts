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
  final voicesResponse = await AzureTts.getAvailableVoices();

  //List all available voices
  print("${voicesResponse.voices}");

  //Pick a Neural voice
  final voice = voicesResponse.voices
      .where((element) => element.locale.startsWith("en-"))
      .toList(growable: false).first;
```

Request audio file.

```dart
   //Generate Audio for a text
  final text = "Microsoft Speech Service Text-to-Speech API is awesome";

  TtsParams params = TtsParams(
      voice: voice,
      audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3,
      rate: 1.5, // optional prosody rate (default is 1.0)
      text: text);

  final ttsResponse = await AzureTts.getTts(params);

  //Get the audio bytes.
  final audioBytes = ttsResponse.audio.buffer.asByteData(); // you can save these bytes to a file for later playback
```

You can also optionally specify a speech style, for voices that support them:

```dart
TtsParams params = TtsParams(
    voice: voice,
    audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3,
    text: text,
    style: 'cheerful',
    styleDegree: 1.5, // optional intensity of the style (0.01 - 2.0)
);
```
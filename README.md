# flutter_azure_tts

Flutter implementation of [Microsoft Azure Cognitive Text-To-Speech API](https://azure.microsoft.com/en-us/services/cognitive-services/text-to-speech/#features) with advanced streaming capabilities, comprehensive error handling, and modern Flutter architecture.

## 🚀 Features

- **Standard TTS**: Generate complete audio files from text
- **Streaming TTS**: Real-time audio streaming for lower latency
- **Voice Filtering**: Advanced filtering API for finding the perfect voice
- **Comprehensive Error Handling**: Specific exception types for different error scenarios
- **Caching System**: Built-in caching for voices and audio to improve performance
- **Retry Logic**: Configurable retry policies with exponential backoff
- **Builder Pattern**: Fluent API for constructing TTS parameters
- **Type Safety**: Strong typing throughout the library
- **Thread Safety**: Safe to use from multiple isolates

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_azure_tts: ^0.2.3
```

## 🏁 Getting Started

### 1. Initialize the Framework

Initialize with your Azure subscription key and region:

```dart
import 'package:flutter_azure_tts/flutter_azure_tts.dart';

// Basic initialization
FlutterAzureTts.init(
  subscriptionKey: "YOUR_SUBSCRIPTION_KEY",
  region: "YOUR_REGION",
  withLogs: true,
);

// Advanced initialization with custom configuration
FlutterAzureTts.init(
  subscriptionKey: "YOUR_SUBSCRIPTION_KEY",
  region: "YOUR_REGION",
  withLogs: true,
  retryPolicy: RetryPolicy(
    maxRetries: 5,
    baseDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 30),
  ),
  requestTimeout: Duration(seconds: 45),
);
```

### 2. Get Available Voices

Retrieve and filter voices using the advanced filtering API:

```dart
try {
  // Get all available voices
  final voicesResponse = await FlutterAzureTts.getAvailableVoices();
  
  // Use the powerful filtering API
  final voice = voicesResponse.voices
      .filter()
      .byLocale('en-US')
      .neural()
      .withStyles()
      .firstOrThrow;
  
  print('Selected voice: ${voice.displayName}');
  print('Available styles: ${voice.styles.map((s) => s.styleName).join(', ')}');
  
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on ServiceUnavailableException catch (e) {
  print('Azure service unavailable: ${e.message}');
}
```

### 3. Generate Speech (Standard TTS)

Use the builder pattern for type-safe parameter construction:

```dart
try {
  // Build parameters with validation
  final params = TtsParamsBuilder()
      .voice(selectedVoice)
      .text('Hello! This is Azure Text-to-Speech.')
      .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
      .rate(1.2) // 20% faster than normal
      .style(StyleSsml(
        style: VoiceStyle.cheerful,
        styleDegree: 1.5,
      ))
      .role(VoiceRole.YoungAdultFemale)
      .build();

  // Generate audio
  final audioResponse = await FlutterAzureTts.getTts(params);
  
  // Save or play the audio
  final audioBytes = audioResponse.audio;
  await File('output.mp3').writeAsBytes(audioBytes);
  
} on ValidationException catch (e) {
  print('Invalid parameters: ${e.message}');
} on RateLimitException catch (e) {
  print('Rate limited. Retry after: ${e.retryAfter}');
} on AuthenticationException catch (e) {
  print('Authentication failed: ${e.message}');
}
```

## 🎵 Streaming TTS (Real-time Audio)

For lower latency and better user experience, use streaming TTS:

### Basic Streaming

```dart
try {
  // Configure streaming parameters
  final streamingParams = TtsStreamingParamsBuilder()
      .voice(selectedVoice)
      .text('This audio will stream in real-time!')
      .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
      .preferredChunkSize(ChunkSize.small)
      .bufferStrategy(BufferStrategy.lowLatency)
      .enableProgressTracking(true)
      .build();

  // Get streaming audio
  final audioStreamResponse = await FlutterAzureTts.getTtsStream(streamingParams);
  
  // Process audio chunks in real-time
  await for (final chunk in audioStreamResponse.audioStream) {
    print('Received chunk ${chunk.sequenceNumber}: ${chunk.size} bytes');
    
    // Add chunk to audio player for immediate playback
    audioPlayer.addChunk(chunk.data);
    
    if (chunk.isLast) {
      print('Streaming completed');
      break;
    }
  }
  
} on NetworkException catch (e) {
  print('Streaming failed: ${e.message}');
}
```

### Streaming with Progress Tracking

```dart
// Get streaming with detailed progress information
final (audioStream, progressStream) = await FlutterAzureTts.getTtsStreamWithProgress(streamingParams);

// Monitor progress for UI updates
progressStream.listen((progress) {
  final percent = progress.percentComplete ?? 0.0;
  print('Progress: ${(percent * 100).toStringAsFixed(1)}%');
  print('Speed: ${progress.bytesPerSecond.toStringAsFixed(1)} B/s');
  updateProgressBar(percent);
});

// Process audio chunks
await for (final chunk in audioStream.audioStream) {
  audioPlayer.addChunk(chunk.data);
}
```

### Optimized Streaming Configurations

```dart
// Real-time voice assistant (minimal latency)
final realtimeParams = TtsStreamingParamsBuilder.forRealtime()
    .voice(assistantVoice)
    .text(userQuery)
    .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
    .build();

// High-quality narration (smooth playback)
final qualityParams = TtsStreamingParamsBuilder.forHighQuality()
    .voice(narratorVoice)
    .text(longText)
    .audioFormat(AudioOutputFormat.audio24khz96kBitrateMonoMp3)
    .build();

// Balanced performance (general use)
final balancedParams = TtsStreamingParamsBuilder.balanced()
    .voice(generalVoice)
    .text(articleText)
    .audioFormat(AudioOutputFormat.audio16khz64kBitrateMonoMp3)
    .build();
```

## 🔍 Advanced Voice Filtering

The library provides a powerful, chainable filtering API:

```dart
final voices = await FlutterAzureTts.getAvailableVoices();

// Find English neural voices with emotional styles
final emotionalVoices = voices.voices
    .filter()
    .byLocale('en-')
    .neural()
    .withStyles()
    .results;

// Find a specific voice for customer service
final serviceVoice = voices.voices
    .filter()
    .byLocale('en-US')
    .byGender('Female')
    .withStyle(VoiceStyle.customerservice)
    .first;

// Search voices by name
final jennyVoices = voices.voices
    .filter()
    .search('jenny')
    .results;

// Complex filtering with multiple criteria
final perfectVoice = voices.voices
    .filter()
    .byLocale('en-US')
    .neural()
    .byGender('Female')
    .withStyles()
    .withRole(VoiceRole.YoungAdultFemale)
    .search('aria')
    .firstOrThrow;
```

## 🎭 Voice Styles and Roles

Enhance your speech with expressive styles and character roles:

```dart
// Available styles (varies by voice)
VoiceStyle.cheerful
VoiceStyle.sad
VoiceStyle.excited
VoiceStyle.friendly
VoiceStyle.hopeful
VoiceStyle.shouting
VoiceStyle.whispering
VoiceStyle.newscast
VoiceStyle.customerservice
// ... and many more

// Available roles (varies by voice)
VoiceRole.YoungAdultFemale
VoiceRole.YoungAdultMale
VoiceRole.OlderAdultFemale
VoiceRole.OlderAdultMale
VoiceRole.SeniorFemale
VoiceRole.SeniorMale
VoiceRole.Girl
VoiceRole.Boy

// Example with style and role
final params = TtsParamsBuilder()
    .voice(voice)
    .text('Welcome to our customer service!')
    .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
    .style(StyleSsml(
      style: VoiceStyle.customerservice,
      styleDegree: 1.2, // Intensity: 0.01 - 2.0
    ))
    .role(VoiceRole.YoungAdultFemale)
    .build();
```

## ⚙️ Configuration and Error Handling

### Retry Policies

Configure how the library handles transient failures:

```dart
// Conservative retry policy
final conservativePolicy = RetryPolicy(
  maxRetries: 2,
  baseDelay: Duration(seconds: 1),
  maxDelay: Duration(seconds: 10),
);

// Aggressive retry policy with jitter
final aggressivePolicy = RetryPolicy(
  maxRetries: 5,
  baseDelay: Duration(milliseconds: 100),
  maxDelay: Duration(seconds: 30),
  backoffMultiplier: 1.5,
  jitter: true,
);

FlutterAzureTts.init(
  subscriptionKey: "YOUR_KEY",
  region: "YOUR_REGION",
  retryPolicy: aggressivePolicy,
);
```

### Comprehensive Error Handling

The library provides specific exception types for different error scenarios:

```dart
try {
  final audio = await FlutterAzureTts.getTts(params);
} on InitializationException catch (e) {
  // Configuration or setup errors
  print('Initialization failed: ${e.message}');
} on AuthenticationException catch (e) {
  // Authentication and authorization errors
  print('Authentication failed: ${e.message}');
} on ValidationException catch (e) {
  // Input validation errors
  print('Invalid parameters: ${e.message}');
} on NetworkException catch (e) {
  // Network connectivity errors
  print('Network error: ${e.message}');
} on RateLimitException catch (e) {
  // API rate limiting
  print('Rate limited. Retry after: ${e.retryAfter}');
} on ServiceUnavailableException catch (e) {
  // Azure service availability
  print('Service unavailable: ${e.message}');
} on AzureTtsException catch (e) {
  // Any other Azure TTS error
  print('Azure TTS error: ${e.message}');
}
```

## 💾 Caching

The library includes built-in caching for improved performance:

```dart
// Audio caching is automatic, but you can control it
final audioCache = AudioCache();

// Check cache before making API call
var audio = audioCache.get(text, voice.shortName, format, rate);
if (audio == null) {
  // Generate new audio
  final response = await FlutterAzureTts.getTts(params);
  audio = response.audio;
  
  // Cache for future use (1 hour TTL)
  audioCache.put(text, voice.shortName, format, rate, audio);
}

// Custom TTL for different content types
audioCache.putWithTtl(
  'Static welcome message',
  voice.shortName,
  format,
  1.0,
  audioData,
  Duration(days: 1), // Cache for 1 day
);
```

## 🏗️ Architecture

The library is organized into logical modules:

```
lib/src/
├── audio/
│   ├── core/           # Core audio functionality
│   ├── streaming/      # Real-time streaming
│   ├── client/         # HTTP clients
│   ├── handlers/       # Request orchestration
│   └── caching/        # Performance optimization
├── auth/               # Authentication management
├── voices/             # Voice management and filtering
├── tts/                # TTS parameter builders
├── common/             # Shared utilities
└── ssml/               # SSML generation
```

## 📊 Performance Tips

### For Standard TTS
- Use caching for repeated content
- Choose appropriate audio formats for your use case
- Implement proper error handling with retries

### For Streaming TTS
- Use `ChunkSize.small` for real-time applications
- Use `ChunkSize.large` for high-quality playback
- Enable progress tracking for UI updates
- Choose buffer strategy based on your latency requirements

### Audio Formats
```dart
// For real-time applications
AudioOutputFormat.audio16khz32kBitrateMonoMp3

// For high-quality playback
AudioOutputFormat.audio24khz96kBitrateMonoMp3

// For bandwidth-constrained environments
AudioOutputFormat.audio16khz32kBitrateMonoMp3
```

## 🔧 Migration from Previous Versions

### From 0.2.2 to 0.2.3

The public API remains the same, but internal improvements include:

```dart
// Old way (still works)
FlutterAzureTts.init(
  subscriptionKey: "key",
  region: "region",
);

// New way (recommended)
FlutterAzureTts.init(
  subscriptionKey: "key",
  region: "region",
  retryPolicy: RetryPolicy(maxRetries: 3),
  requestTimeout: Duration(seconds: 30),
);

// Old parameter creation (still works)
final params = TtsParams(
  voice: voice,
  text: text,
  audioFormat: format,
);

// New parameter creation (recommended)
final params = TtsParamsBuilder()
    .voice(voice)
    .text(text)
    .audioFormat(format)
    .build();
```

## 📚 Examples

Check out the `example/` directory for comprehensive examples:

- `example.dart` - Command-line tool with advanced options
- `improved_example.dart` - Modern API usage patterns
- `streaming_example.dart` - Real-time streaming examples
- `main.dart` - Basic usage example

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Azure Text-to-Speech Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/text-to-speech)
- [Azure Speech Service](https://azure.microsoft.com/en-us/services/cognitive-services/speech-services/)
- [Package on pub.dev](https://pub.dev/packages/flutter_azure_tts)

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/)
2. Search existing [issues](https://github.com/ghuyfel/flutter_azure_tts/issues)
3. Create a new issue with detailed information

---

Made with ❤️ for the Flutter community
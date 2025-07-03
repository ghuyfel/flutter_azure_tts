import 'package:flutter_azure_tts/src/audio/audio_output_format.dart';
import 'package:flutter_azure_tts/src/ssml/style_ssml.dart';
import 'package:flutter_azure_tts/src/tts/tts_params.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';

/// Builder pattern implementation for creating [TtsParams] with comprehensive validation.
/// 
/// This class provides a fluent interface for constructing text-to-speech parameters
/// while ensuring all values are valid and compatible. It performs extensive validation
/// to catch configuration errors early and provide helpful error messages.
/// 
/// ## Benefits of the Builder Pattern
/// 
/// - **Fluent Interface**: Method chaining for readable code
/// - **Validation**: Early detection of invalid parameter combinations
/// - **Type Safety**: Compile-time checking of parameter types
/// - **Flexibility**: Optional parameters with sensible defaults
/// - **Error Prevention**: Compatibility checking between voice and style/role
/// 
/// ## Usage
/// 
/// ```dart
/// final params = TtsParamsBuilder()
///     .voice(selectedVoice)
///     .text('Hello, world!')
///     .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
///     .rate(1.2)
///     .style(StyleSsml(style: VoiceStyle.cheerful, styleDegree: 1.5))
///     .role(VoiceRole.YoungAdultFemale)
///     .build();
/// ```
/// 
/// ## Validation Rules
/// 
/// - Text cannot be empty or exceed 10,000 characters
/// - Speech rate must be between 0.5 and 3.0
/// - Voice must support the specified style (if provided)
/// - Voice must support the specified role (if provided)
/// - All required fields must be set before calling [build]
class TtsParamsBuilder {
  /// The selected voice for speech synthesis.
  Voice? _voice;
  
  /// The text to be converted to speech.
  String? _text;
  
  /// The desired audio output format.
  String? _audioFormat;
  
  /// The speech rate (speed) multiplier.
  double? _rate;
  
  /// Optional style configuration for expressive speech.
  StyleSsml? _style;
  
  /// Optional role for voice character imitation.
  VoiceRole? _role;

  /// Sets the voice to use for speech synthesis.
  /// 
  /// The voice determines the language, gender, and available features
  /// for the generated speech. Different voices support different styles
  /// and roles, which will be validated when [build] is called.
  /// 
  /// ## Parameters
  /// 
  /// - [voice]: The voice to use. Must not be null.
  /// 
  /// ## Returns
  /// 
  /// This builder instance for method chaining.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final builder = TtsParamsBuilder()
  ///     .voice(englishVoice);
  /// ```
  TtsParamsBuilder voice(Voice voice) {
    _voice = voice;
    return this;
  }

  /// Sets the text to be converted to speech.
  /// 
  /// The text is validated to ensure it meets Azure TTS requirements:
  /// - Cannot be empty
  /// - Cannot exceed 10,000 characters
  /// - Should be plain text or valid SSML
  /// 
  /// ## Parameters
  /// 
  /// - [text]: The text to synthesize. Must be non-empty and ≤ 10,000 characters.
  /// 
  /// ## Returns
  /// 
  /// This builder instance for method chaining.
  /// 
  /// ## Throws
  /// 
  /// - [ArgumentError]: If text is empty or too long.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final builder = TtsParamsBuilder()
  ///     .text('Hello, this is a test of Azure TTS!');
  /// ```
  TtsParamsBuilder text(String text) {
    if (text.isEmpty) {
      throw ArgumentError('Text cannot be empty');
    }
    if (text.length > 10000) {
      throw ArgumentError('Text cannot exceed 10,000 characters (current: ${text.length})');
    }
    _text = text;
    return this;
  }

  /// Sets the audio output format.
  /// 
  /// The format determines the encoding, sample rate, and quality of the
  /// generated audio. Use constants from [AudioOutputFormat] for valid options.
  /// 
  /// ## Parameters
  /// 
  /// - [format]: The audio format string. Use [AudioOutputFormat] constants.
  /// 
  /// ## Returns
  /// 
  /// This builder instance for method chaining.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final builder = TtsParamsBuilder()
  ///     .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3);
  /// ```
  TtsParamsBuilder audioFormat(String format) {
    _audioFormat = format;
    return this;
  }

  /// Sets the speech rate (speed) multiplier.
  /// 
  /// The rate controls how fast or slow the speech is generated:
  /// - 0.5: Half speed (very slow)
  /// - 1.0: Normal speed (default)
  /// - 2.0: Double speed (fast)
  /// - 3.0: Triple speed (very fast)
  /// 
  /// ## Parameters
  /// 
  /// - [rate]: Speech rate multiplier. Must be between 0.5 and 3.0 inclusive.
  /// 
  /// ## Returns
  /// 
  /// This builder instance for method chaining.
  /// 
  /// ## Throws
  /// 
  /// - [ArgumentError]: If rate is outside the valid range.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final builder = TtsParamsBuilder()
  ///     .rate(1.2); // 20% faster than normal
  /// ```
  TtsParamsBuilder rate(double rate) {
    if (rate < 0.5 || rate > 3.0) {
      throw ArgumentError('Rate must be between 0.5 and 3.0 (current: $rate)');
    }
    _rate = rate;
    return this;
  }

  /// Sets the speech style for expressive synthesis.
  /// 
  /// Styles allow the voice to express different emotions or speaking patterns.
  /// Not all voices support styles, and compatibility will be validated when
  /// [build] is called.
  /// 
  /// ## Parameters
  /// 
  /// - [style]: The style configuration including style type and intensity.
  /// 
  /// ## Returns
  /// 
  /// This builder instance for method chaining.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final builder = TtsParamsBuilder()
  ///     .style(StyleSsml(
  ///       style: VoiceStyle.cheerful,
  ///       styleDegree: 1.5,
  ///     ));
  /// ```
  TtsParamsBuilder style(StyleSsml style) {
    _style = style;
    return this;
  }

  /// Sets the voice role for character imitation.
  /// 
  /// Roles allow the voice to imitate different age groups and genders.
  /// Not all voices support roles, and compatibility will be validated when
  /// [build] is called.
  /// 
  /// ## Parameters
  /// 
  /// - [role]: The role to imitate.
  /// 
  /// ## Returns
  /// 
  /// This builder instance for method chaining.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final builder = TtsParamsBuilder()
  ///     .role(VoiceRole.YoungAdultFemale);
  /// ```
  TtsParamsBuilder role(VoiceRole role) {
    _role = role;
    return this;
  }

  /// Builds and validates the final [TtsParams] object.
  /// 
  /// This method performs comprehensive validation of all parameters:
  /// 1. Ensures all required fields are set
  /// 2. Validates parameter values and ranges
  /// 3. Checks voice compatibility with styles and roles
  /// 4. Creates the final immutable [TtsParams] object
  /// 
  /// ## Returns
  /// 
  /// A validated [TtsParams] object ready for use with Azure TTS.
  /// 
  /// ## Throws
  /// 
  /// - [ArgumentError]: If required fields are missing or invalid.
  /// - [ArgumentError]: If the voice doesn't support the specified style or role.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// try {
  ///   final params = TtsParamsBuilder()
  ///       .voice(selectedVoice)
  ///       .text('Hello world')
  ///       .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
  ///       .build();
  ///   
  ///   // Use params for TTS
  ///   final audio = await FlutterAzureTts.getTts(params);
  /// } on ArgumentError catch (e) {
  ///   print('Invalid parameters: ${e.message}');
  /// }
  /// ```
  TtsParams build() {
    // Validate required fields
    final voice = _voice;
    final text = _text;
    final audioFormat = _audioFormat;

    if (voice == null) {
      throw ArgumentError('Voice is required. Call voice() before build().');
    }
    if (text == null) {
      throw ArgumentError('Text is required. Call text() before build().');
    }
    if (audioFormat == null) {
      throw ArgumentError('Audio format is required. Call audioFormat() before build().');
    }

    // Validate style compatibility
    if (_style != null && !voice.styles.contains(_style!.style)) {
      throw ArgumentError(
        'Voice "${voice.shortName}" does not support style "${_style!.style.styleName}". '
        'Supported styles: ${voice.styles.map((s) => s.styleName).join(', ')}'
      );
    }

    // Validate role compatibility
    if (_role != null && !voice.roles.contains(_role!)) {
      throw ArgumentError(
        'Voice "${voice.shortName}" does not support role "$_role". '
        'Supported roles: ${voice.roles.join(', ')}'
      );
    }

    // Create and return the validated TtsParams
    return TtsParams(
      voice: voice,
      audioFormat: audioFormat,
      text: text,
      rate: _rate,
      style: _style,
      role: _role,
    );
  }

  /// Resets all builder state to allow reuse.
  /// 
  /// This clears all previously set values, allowing the builder to be
  /// reused for creating multiple [TtsParams] objects.
  /// 
  /// ## Returns
  /// 
  /// This builder instance for method chaining.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final builder = TtsParamsBuilder();
  /// 
  /// // Build first params
  /// final params1 = builder
  ///     .voice(voice1)
  ///     .text('First text')
  ///     .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3)
  ///     .build();
  /// 
  /// // Reset and build second params
  /// final params2 = builder
  ///     .reset()
  ///     .voice(voice2)
  ///     .text('Second text')
  ///     .audioFormat(AudioOutputFormat.audio24khz48kBitrateMonoMp3)
  ///     .build();
  /// ```
  TtsParamsBuilder reset() {
    _voice = null;
    _text = null;
    _audioFormat = null;
    _rate = null;
    _style = null;
    _role = null;
    return this;
  }

  /// Creates a copy of this builder with the current state.
  /// 
  /// This is useful for creating variations of a base configuration
  /// without modifying the original builder.
  /// 
  /// ## Returns
  /// 
  /// A new [TtsParamsBuilder] with the same state as this one.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final baseBuilder = TtsParamsBuilder()
  ///     .voice(commonVoice)
  ///     .audioFormat(AudioOutputFormat.audio16khz32kBitrateMonoMp3);
  /// 
  /// // Create variations
  /// final cheerfulParams = baseBuilder
  ///     .copy()
  ///     .text('Happy message!')
  ///     .style(StyleSsml(style: VoiceStyle.cheerful))
  ///     .build();
  /// 
  /// final sadParams = baseBuilder
  ///     .copy()
  ///     .text('Sad message...')
  ///     .style(StyleSsml(style: VoiceStyle.sad))
  ///     .build();
  /// ```
  TtsParamsBuilder copy() {
    final newBuilder = TtsParamsBuilder();
    newBuilder._voice = _voice;
    newBuilder._text = _text;
    newBuilder._audioFormat = _audioFormat;
    newBuilder._rate = _rate;
    newBuilder._style = _style;
    newBuilder._role = _role;
    return newBuilder;
  }

  @override
  String toString() {
    return 'TtsParamsBuilder('
        'voice: ${_voice?.shortName}, '
        'text: ${_text?.length} chars, '
        'audioFormat: $_audioFormat, '
        'rate: $_rate, '
        'style: ${_style?.styleName}, '
        'role: $_role'
        ')';
  }
}
import 'package:flutter_azure_tts/flutter_azure_tts.dart';

class StyleSsml {
  ///[style] The voice-specific speaking style. You can express emotions like cheerfulness,
  ///empathy, and calmness. You can also optimize the voice for different scenarios
  ///like customer service,newscast, and voice assistant.
  final VoiceStyle style;

  /// [styleDegree] The intensity of the speaking style.
  /// You can specify a stronger or softer style to make the speech more expressive or subdued.
  /// The range of accepted values are: 0.01 to 2 inclusive. The default value is 1
  final double styleDegree;

  StyleSsml({required this.style, this.styleDegree = 1.0}) {
    assert(styleDegree >= 0.01 && styleDegree <= 2);
  }

  String get styleName => style.styleName;
}

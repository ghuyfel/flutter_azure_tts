import 'package:flutter_azure_tts/src/ssml/style_ssml.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';

//Parameters definition from : https://learn.microsoft.com/en-us/azure/ai-services/speech-service/speech-synthesis-markup-voice
class AudioRequestParams {
  final Voice voice;
  final String text;
  final String audioFormat;
  final double? rate;
  final StyleSsml? style;

  ///[role] The speaking role-play. The voice can imitate a different age and gender,
  ///but the voice name isn't changed. For example, a male voice can raise the pitch
  ///and change the intonation to imitate a female voice, but the voice name isn't changed.
  ///If the role is missing or isn't supported for your voice, this attribute is ignored.
  final VoiceRole? role;

  const AudioRequestParams({
    required this.voice,
    required this.text,
    required this.audioFormat,
    this.rate = 1,
    this.style,
    this.role,
  });
}

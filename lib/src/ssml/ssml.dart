import 'package:flutter_azure_tts/src/ssml/style_ssml.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';

class Ssml {
  const Ssml({
    required this.voice,
    required this.text,
    required this.speed,
    this.style,
    this.role,
  });

  final Voice voice;
  final String text;
  final double speed;
  final StyleSsml? style;
  final VoiceRole? role;

  @override
  String toString() => buildSsml;

  String get buildSsml {
    return "<speak version='1.0' "
        "xmlns='http://www.w3.org/2001/10/synthesis' "
        "xml:lang='${voice.locale}'>"
        "<voice xml:lang='${voice.locale}' "
        "xml:gender='${voice.gender}' "
        "${style != null ? "xml:style='${style!.styleName}' " : ""}"
        "${role != null ? "xml:role='${role!.name}' " : ""}"
        "${style?.styleDegree != null ? "xml:styledegree='${style!.styleDegree}' " : ""}"
        "name='${voice.shortName}'>"
        "<prosody rate='$speed'>"
        "$text"
        "<\/prosody><\/voice><\/speak>";
  }
}

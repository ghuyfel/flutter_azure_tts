import 'package:flutter_azure_tts/src/voices/voice_model.dart';

class Ssml {
  Ssml({required this.voice, required this.text});

  final Voice voice;
  final String text;

  String get buildSsml {
    return "<speak version='1.0' "
        "xmlns='http://www.w3.org/2001/10/synthesis' "
        "xml:lang='${voice.locale}'>"
        "<voice xml:lang='${voice.locale}' "
        "xml:gender='${voice.gender}' "
        "name='${voice.shortName}'>"
        "$text"
        "<\/voice><\/speak>";
  }
}

import 'package:flutter_azure_tts/src/common/config.dart';

class Endpoints {
  Endpoints._();

  ///Endpoint used to get Access Token for requests authentication.
  static String get issueToken =>
      "https://${Config.region}.api.cognitive.microsoft.com/sts/v1.0/issueToken";

  ///Endpoint used to get the list of voices supported by the endpoint.
  static String get voicesList =>
      "https://${Config.region}.tts.speech.microsoft.com/cognitiveservices/voices/list";

  ///Endpoint used to get the list of voices supported by the endpoint.
  static String get customVoicesList =>
      "https://${Config.region}.voice.speech.microsoft.com/cognitiveservices/v1?deploymentId=";

  static String get longAudio =>
      "https://${Config.region}.customvoice.api.speech.microsoft.com";

  static String get audio =>
      "https://${Config.region}.tts.speech.microsoft.com/cognitiveservices/v1";
}

class Constants {
  static Duration get authRefreshDuration => Duration(minutes: 8);
}

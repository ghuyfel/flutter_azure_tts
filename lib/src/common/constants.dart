import 'package:flutter_azure_tts/src/common/azure_tts_config.dart';

class Endpoints {
  Endpoints._();

  static String get issueToken {
    final config = ConfigManager().config;
    return "https://${config.region}.api.cognitive.microsoft.com/sts/v1.0/issueToken";
  }

  static String get voicesList {
    final config = ConfigManager().config;
    return "https://${config.region}.tts.speech.microsoft.com/cognitiveservices/voices/list";
  }

  static String get customVoicesList {
    final config = ConfigManager().config;
    return "https://${config.region}.voice.speech.microsoft.com/cognitiveservices/v1?deploymentId=";
  }

  static String get longAudio {
    final config = ConfigManager().config;
    return "https://${config.region}.customvoice.api.speech.microsoft.com";
  }

  static String get audio {
    final config = ConfigManager().config;
    return "https://${config.region}.tts.speech.microsoft.com/cognitiveservices/v1";
  }
}

class Constants {
  Constants._();
  
  static const Duration authRefreshDuration = Duration(minutes: 8);
  static const int maxTextLength = 10000;
  static const int maxRetries = 3;
  static const Duration defaultTimeout = Duration(seconds: 30);
  
  // Rate limits
  static const int maxRequestsPerSecond = 20;
  static const int maxRequestsPerMinute = 200;
}
import 'package:azure_tts/src/audio/audio_client.dart';
import 'package:azure_tts/src/audio/audio_request_param.dart';
import 'package:azure_tts/src/audio/audio_response_mapper.dart';
import 'package:azure_tts/src/audio/audio_responses.dart';
import 'package:azure_tts/src/auth/authentication_types.dart';
import 'package:azure_tts/src/common/config.dart';
import 'package:azure_tts/src/common/constants.dart';
import 'package:azure_tts/src/ssml/ssml.dart';
import 'package:http/http.dart' as http;

import 'audio_type_header.dart';

class AudioHandler {
  Future<AudioSuccess> getAudio(AudioRequestParams params) async {
    final mapper = AudioResponseMapper();
    final audioClient = AudioClient(
        client: http.Client(),
        authHeader: BearerAuthenticationHeader(token: Config.authToken!.token),
        audioTypeHeader: AudioTypeHeader(audioFormat: params.audioFormat));

    try {
      final ssml =
          Ssml(voice: params.voice, text: params.text, speed: params.rate ?? 1);

      final response = await audioClient.post(Uri.parse(Endpoints.audio),
          body: ssml.buildSsml);
      final audioResponse = mapper.map(response);
      if (audioResponse is AudioSuccess) {
        return audioResponse;
      } else {
        throw audioResponse;
      }
    } catch (e) {
      rethrow;
    }
  }
}

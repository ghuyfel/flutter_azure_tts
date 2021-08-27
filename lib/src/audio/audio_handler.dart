import 'package:flutter_azure_tts/src/audio/audio_client.dart';
import 'package:flutter_azure_tts/src/audio/audio_request_param.dart';
import 'package:flutter_azure_tts/src/audio/audio_response_mapper.dart';
import 'package:flutter_azure_tts/src/audio/audio_responses.dart';
import 'package:flutter_azure_tts/src/auth/authentication_types.dart';
import 'package:flutter_azure_tts/src/common/azure_exception.dart';
import 'package:flutter_azure_tts/src/common/config.dart';
import 'package:flutter_azure_tts/src/common/constants.dart';
import 'package:flutter_azure_tts/src/ssml/ssml.dart';
import 'package:http/http.dart' as http;

import 'audio_type_header.dart';

class AudioHandler {
  Future<AudioResponse> getAudio(AudioRequestParams params) async {
    final mapper = AudioResponseMapper();
    final audioClient = AudioClient(
        client: http.Client(),
        authHeader: BearerAuthenticationHeader(token: Config.token),
        audioTypeHeader: AudioTypeHeader(audioFormat: params.audioFormat));

    final ssml = Ssml(voice: params.voice, text: params.text);

    final response = await audioClient.post(Uri.parse(Endpoints.audio),
        body: ssml.buildSsml);
    final voicesResponse = mapper.map(response) as AudioResponse;
    if (voicesResponse is AudioSuccess)
      return voicesResponse;
    else
      throw AzureException(response: voicesResponse);
  }
}

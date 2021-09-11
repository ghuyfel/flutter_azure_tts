import 'package:flutter_azure_tts/src/auth/authentication_types.dart';
import 'package:flutter_azure_tts/src/common/config.dart';
import 'package:flutter_azure_tts/src/common/constants.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';
import 'package:flutter_azure_tts/src/voices/voices_client.dart';
import 'package:flutter_azure_tts/src/voices/voices_response_mapper.dart';
import 'package:http/http.dart' as http;

class VoicesHandler {
  Future<VoicesResponse> getVoices() async {
    final client = http.Client();
    final header = BearerAuthenticationHeader(token: Config.authToken!.token);
    final voiceClient = VoicesClient(client: client, header: header);

    final mapper = VoicesResponseMapper();
    final response = await voiceClient.get(Uri.parse(Endpoints.voicesList));
    return mapper.map(response) as VoicesResponse;
  }
}

import 'dart:convert';

import 'package:flutter_azure_tts/src/auth/authentication_types.dart';
import 'package:flutter_azure_tts/src/common/azure_exception.dart';
import 'package:flutter_azure_tts/src/common/config.dart';
import 'package:flutter_azure_tts/src/common/constants.dart';
import 'package:flutter_azure_tts/src/voices/voices.dart';
import 'package:flutter_azure_tts/src/voices/voices_client.dart';
import 'package:flutter_azure_tts/src/voices/voices_response_mapper.dart';
import 'package:http/http.dart' as http;

class VoicesHandler {
  late final VoicesClient _client;

  VoicesHandler() {
    final client = http.Client();
    final header = BearerAuthenticationHeader(token: Config.token);
    _client = VoicesClient(client: client, header: header);
  }

  Future<VoicesSuccess> getVoices() async {
    final mapper = VoicesResponseMapper();
    final response = await _client.get(Uri.parse(Endpoints.voicesList));
    final voicesResponse = mapper.map(response);
    if(voicesResponse is VoicesSuccess) return voicesResponse;
    else throw AzureException(response: voicesResponse);
  }
}

import 'dart:async';

import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:flutter_azure_tts/src/auth/auth_client.dart';
import 'package:flutter_azure_tts/src/auth/auth_response_mapper.dart';
import 'package:flutter_azure_tts/src/auth/authentication_types.dart';
import 'package:flutter_azure_tts/src/common/azure_exception.dart';
import 'package:flutter_azure_tts/src/common/config.dart';
import 'package:flutter_azure_tts/src/common/constants.dart';
import 'package:http/http.dart' as http;

class AuthHandler {
  late final AuthClient _authClient;
  late final AuthResponseMapper _mapper;

  Future<bool> init() async {
    final client = http.Client();
    _mapper = AuthResponseMapper();
    final authHeader = SubscriptionKeyAuthenticationHeader(
        subscriptionKey: Config.subscriptionKey);
    _authClient = AuthClient(client: client, authHeader: authHeader);
    await _getToken();
    Timer.periodic(Constants.authRefreshDuration, (timer) => _getToken);
    return true;
  }

  Future<void> _getToken() async {
    print("Requesting Token");
    final response = await _authClient.post(Uri.parse(Endpoints.issueToken));
    final authResponse = _mapper.map(response);
    if (authResponse is TokenSuccess) {
      Config.token = authResponse.token;
      print("Got Token");
    } else {
      throw AzureException(response: authResponse);
    }
  }
}

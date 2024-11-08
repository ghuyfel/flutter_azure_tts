import 'package:azure_tts/src/auth/authentication_types.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

class AuthClient extends http.BaseClient {
  ///Creates an Authorisation HTTP Client.
  ///
  /// [client] : http client to used for requests.
  ///
  /// [authHeader] : Authentication header to be used by this client.
  AuthClient(
      {required http.Client client,
      required AuthenticationTypeHeader authHeader})
      : this._client = RetryClient(client),
        this._authHeader = authHeader;

  final RetryClient _client;
  final AuthenticationTypeHeader _authHeader;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers[_authHeader.type] = _authHeader.headerValue;
    request.headers['Content-Type'] = "application/x-www-form-urlencoded";
    return _client.send(request);
  }
}

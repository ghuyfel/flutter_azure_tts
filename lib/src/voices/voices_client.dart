import 'package:azure_tts/src/auth/authentication_types.dart';
import 'package:azure_tts/src/common/base_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

class VoicesClient extends BaseClient {
  VoicesClient(
      {required http.Client client, required AuthenticationTypeHeader header})
      : super(client: RetryClient(client), header: header);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers[header.type] = header.headerValue;
    return client.send(request);
  }
}

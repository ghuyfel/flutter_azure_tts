import 'package:azure_tts/src/audio/audio_type_header.dart';
import 'package:azure_tts/src/auth/authentication_types.dart';
import 'package:azure_tts/src/common/base_client.dart';
import 'package:http/http.dart' as http;

class AudioClient extends BaseClient {
  AudioClient(
      {required http.Client client,
      required BearerAuthenticationHeader authHeader,
      required AudioTypeHeader audioTypeHeader})
      : _audioTypeHeader = audioTypeHeader,
        super(client: client, header: authHeader);
  final AudioTypeHeader _audioTypeHeader;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers[header.type] = header.value;
    request.headers[_audioTypeHeader.type] = _audioTypeHeader.value;
    request.headers['Content-Type'] = "application/ssml+xml";
    return client.send(request);
  }
}

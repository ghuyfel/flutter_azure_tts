import 'package:azure_tts/src/common/base_header.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

abstract class BaseClient extends http.BaseClient {
  BaseClient({required http.Client client, required BaseHeader header})
      : _header = header,
        _client = RetryClient(client);
  final BaseHeader _header;
  final RetryClient _client;

  BaseHeader get header => _header;

  RetryClient get client => _client;
}

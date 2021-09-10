import 'package:flutter_azure_tts/src/common/base_response.dart';

class AzureException implements Exception {
  AzureException({required this.response});
  final BaseResponse response;

  @override
  String toString() {
    return "[AzureException] ${response.code}: ${response.reason}";
  }
}

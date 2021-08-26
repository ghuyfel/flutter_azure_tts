import 'package:flutter_azure_tts/src/auth/auth.dart';
import 'package:flutter_azure_tts/src/common/base_response.dart';
import 'package:flutter_azure_tts/src/common/base_response_mapper.dart';
import 'package:http/http.dart' as http;

class AuthResponseMapper extends BaseResponseMapper {
  @override
  BaseResponse map(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return TokenSuccess(token: response.body);
      default:
        return TokenFailure(
            code: response.statusCode,
            reason: response.reasonPhrase ?? response.body);
    }
  }
}

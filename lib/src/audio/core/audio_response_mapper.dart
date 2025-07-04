import 'package:flutter_azure_tts/src/audio/core/audio_responses.dart';
import 'package:flutter_azure_tts/src/common/base_response.dart';
import 'package:flutter_azure_tts/src/common/base_response_mapper.dart';
import 'package:http/http.dart' as http;

class AudioResponseMapper extends BaseResponseMapper {
  @override
  BaseResponse map(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return AudioSuccess(audio: response.bodyBytes);
      case 400:
        return AudioFailedBadRequest(reasonPhrase: response.reasonPhrase);
      case 401:
        return AudioFailedUnauthorized();
      case 415:
        return AudioFailedUnsupported();
      case 429:
        return AudioFailedTooManyRequest();
      case 502:
        return AudioFailedBadGateway();
      default:
        return AudioFailedUnkownError(
            code: response.statusCode,
            reason: response.reasonPhrase ?? response.body);
    }
  }
}

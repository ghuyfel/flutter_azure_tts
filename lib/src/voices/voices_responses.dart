import 'package:flutter_azure_tts/src/common/base_response.dart';
import 'package:flutter_azure_tts/src/voices/voice_model.dart';

class VoicesResponse extends BaseResponse {
  VoicesResponse({required int code, required String reason})
      : super(code: code, reason: reason);
}

class VoicesSuccess extends VoicesResponse {
  VoicesSuccess({required this.voices}) : super(code: 200, reason: 'Success');
  final List<Voice> voices;
}

class VoicesFailedBadRequest extends VoicesResponse {
  VoicesFailedBadRequest()
      : super(
            code: 400,
            reason:
                "Bad Request	A required parameter is missing, empty, or null. Or, the value passed to either a required or optional parameter is invalid. A common issue is a header that is too long.");
}

class VoicesFailedUnauthorized extends VoicesResponse {
  VoicesFailedUnauthorized()
      : super(
            code: 401,
            reason:
                "Unauthorized	The request is not authorized. Check to make sure your subscription key or token is valid and in the correct region.");
}

class VoicesFailedTooManyRequests extends VoicesResponse {
  VoicesFailedTooManyRequests()
      : super(
            code: 429,
            reason:
                "Too Many Requests	You have exceeded the quota or rate of requests allowed for your subscription.");
}

class VoicesFailedBadGateWay extends VoicesResponse {
  VoicesFailedBadGateWay()
      : super(
            code: 502,
            reason:
                "Bad Gateway	Network or server-side issue. May also indicate invalid headers.");
}

class VoicesFailedUnkownError extends VoicesResponse {
  VoicesFailedUnkownError({required int code, required String reason})
      : super(code: code, reason: reason);
}

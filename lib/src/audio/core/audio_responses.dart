import 'dart:typed_data';

import 'package:flutter_azure_tts/src/common/base_response.dart';

abstract class AudioResponse extends BaseResponse {
  AudioResponse({required int code, required String reason})
      : super(code: code, reason: reason);
}

///The request was successful.
class AudioSuccess extends AudioResponse {
  AudioSuccess({required this.audio}) : super(code: 200, reason: "Success");

  ///The audio file
  final Uint8List audio;
}

class AudioFailedBadRequest extends AudioResponse {
  AudioFailedBadRequest({String? reasonPhrase})
      : super(
            code: 400,
            reason:
                "Bad Request	A required parameter is missing, empty, or null. Or, the value passed to either a required or optional parameter is invalid. A common issue is a header that is too long. ${reasonPhrase ?? ''}");
}

class AudioFailedUnauthorized extends AudioResponse {
  AudioFailedUnauthorized()
      : super(
            code: 401,
            reason:
                "Unauthorized	The request is not authorized. Check to make sure your subscription key or token is valid and in the correct region.");
}

class AudioFailedUnsupported extends AudioResponse {
  AudioFailedUnsupported()
      : super(
            code: 415,
            reason:
                "Unsupported Media Type	It's possible that the wrong Content-Type was provided. Content-Type should be set to application/ssml+xml.");
}

class AudioFailedTooManyRequest extends BaseResponse {
  AudioFailedTooManyRequest()
      : super(
            code: 429,
            reason:
                "Too Many Requests	You have exceeded the quota or rate of requests allowed for your subscription.");
}

class AudioFailedBadGateway extends AudioResponse {
  AudioFailedBadGateway()
      : super(
            code: 502,
            reason:
                "Bad Gateway	Network or server-side issue. May also indicate invalid headers.");
}

class AudioFailedUnkownError extends AudioResponse {
  AudioFailedUnkownError({required int code, required String reason})
      : super(code: code, reason: reason);
}

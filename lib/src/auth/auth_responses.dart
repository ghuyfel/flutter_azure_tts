import 'package:flutter_azure_tts/src/common/base_response.dart';

///Represents the response object of a token request.
///Must be implemented by all the response cases objects.
abstract class AuthResponse extends BaseResponse {
  AuthResponse({required int code, required String reason})
      : super(reason: reason, code: code);
}

///Token request success response.
class TokenSuccess extends AuthResponse {
  ///[token] Authorisation token.
  TokenSuccess({required this.token}) : super(code: 200, reason: "Success");
  final String token;
}

///Token request failed.
class TokenFailure extends AuthResponse {
  ///[code] The http response code.
  ///
  /// [reason] The http failure reason.
  TokenFailure({required int code, required String reason})
      : super(code: code, reason: reason);
}

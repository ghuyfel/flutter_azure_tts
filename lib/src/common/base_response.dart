///Represents the response object of a token request.
///Must be implemented by all the response cases objects.
abstract class BaseResponse {
  BaseResponse({required this.code, required this.reason});
  final String reason;
  final int code;

  @override
  String toString() {
    return "$code: $reason";
  }
}

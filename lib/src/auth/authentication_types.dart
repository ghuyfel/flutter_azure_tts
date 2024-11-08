import 'package:azure_tts/src/common/base_header.dart';

///Base class that all authentications types must implement.
abstract class AuthenticationTypeHeader extends BaseHeader {
  ///[type] The type of Microsoft Authorisation Header to use.
  ///[value] The value assigned to the [type].
  AuthenticationTypeHeader({required String type, required String value})
      : super(type: type, value: value);
}

///Authentication using Authorisation header type.
///
/// *Note: the [authToken] must be refreshed every 9 minutes*.
class BearerAuthenticationHeader extends AuthenticationTypeHeader {
  BearerAuthenticationHeader({required String token})
      : super(type: "Authorization", value: token);

  @override
  String get headerValue => "Bearer $value";
}

///Authentication using Ocp-Apim-Subscription-Key header type
class SubscriptionKeyAuthenticationHeader extends AuthenticationTypeHeader {
  SubscriptionKeyAuthenticationHeader({required String subscriptionKey})
      : super(type: "Ocp-Apim-Subscription-Key", value: subscriptionKey);

  @override
  String get headerValue => value;
}

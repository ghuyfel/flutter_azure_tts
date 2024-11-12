import 'package:azure_tts/src/auth/auth_token.dart';

///Holds all configurations
class Config {
  static AuthToken? authToken;

  Config._();

  ///Subscription key for the endpoint/region you plan to use
  static late final String subscriptionKey;

  ///Region identifier i.e. [centralus]
  static late final String region;

  ///Initialise the config by setting endpoint region and subscription key
  static void init(
      {required String endpointRegion, required String endpointSubKey}) {
    region = endpointRegion;
    subscriptionKey = endpointSubKey;
  }
}

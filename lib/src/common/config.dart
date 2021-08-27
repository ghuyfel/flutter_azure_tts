class Config {
  static String token = "";

  Config._();

  ///Subscription key for the endpoint/region you plan to use
  static late final String subscriptionKey;

  ///Region identifier i.e. [centralus]
  static late final String region;

  static void init(
      {required String endpointRegion, required String endpointSubKey}) {
    region = endpointRegion;
    subscriptionKey = endpointSubKey;
  }
}

import 'package:azure_tts/src/auth/auth_client.dart';
import 'package:azure_tts/src/auth/auth_responses.dart';
import 'package:azure_tts/src/auth/authentication_types.dart';
import 'package:azure_tts/src/common/config.dart';
import 'package:azure_tts/src/common/constants.dart';
import 'package:http/http.dart' as http;

class Authentication {
  static Future<AuthResponse> getToken() async {
    final client = http.Client();
    final header = SubscriptionKeyAuthenticationHeader(
        subscriptionKey: Config.subscriptionKey);
    final authClient = AuthClient(client: client, authHeader: header);
    final response = await authClient.post(Uri.parse(Endpoints.issueToken));

    if (response.statusCode == 200) {
      return TokenSuccess(token: response.body);
    } else {
      return TokenFailure(
          code: response.statusCode,
          reason: response.reasonPhrase ??
              "Something went wrong: ${response.body}");
    }
  }
}

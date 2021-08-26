import 'dart:convert';

import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:flutter_azure_tts/src/common/base_response.dart';
import 'package:flutter_azure_tts/src/common/base_response_mapper.dart';
import 'package:http/http.dart' as http;

class VoicesResponseMapper extends BaseResponseMapper {
  @override
  BaseResponse map(http.Response response) {
    switch (response.statusCode) {
      case 200:
        {
          final json = jsonDecode(response.body) as List<dynamic>;
          final voices = json
              .map((e) => Voice.fromJson(e as Map<String, dynamic>))
              .toList(growable: false);

          return VoicesSuccess(voices: voices);
        }
      case 400:
        return VoicesFailedBadRequest();
      case 401:
        return VoicesFailedUnauthorized();
      case 429:
        return VoicesFailedTooManyRequests();
      case 502:
        return VoicesFailedBadGateWay();
      default:
        return VoicesFailedUnkownError(
            code: response.statusCode,
            reason: response.reasonPhrase ?? response.body);
    }
  }
}

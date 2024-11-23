import 'dart:convert';

import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:flutter_azure_tts/src/common/base_response.dart';
import 'package:flutter_azure_tts/src/common/base_response_mapper.dart';
import 'package:flutter_azure_tts/src/mappers/voice_data_to_voice_model_mapper.dart';
import 'package:flutter_azure_tts/src/voices/voice_data.dart';
import 'package:http/http.dart' as http;

class VoicesResponseMapper extends BaseResponseMapper {
  @override
  BaseResponse map(http.Response response) {
    switch (response.statusCode) {
      case 200:
        {
          final json = jsonDecode(response.body) as List<dynamic>;
          final voices = json
              .map((e) => VoiceData.fromJson(e as Map<String, dynamic>))
              .toList(growable: false);

          return VoicesSuccess(
              voices: VoiceDataToVoiceModelMapper().toModelList(voices));
        }
      case 400:
        return VoicesFailedBadRequest(reasonPhrase: response.reasonPhrase);
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

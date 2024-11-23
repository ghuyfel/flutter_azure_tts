import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:json_annotation/json_annotation.dart';

part 'voice_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.none, explicitToJson: true)
class Voice {
  final String name;
  final String displayName;
  final String localName;
  final String shortName;
  final String gender;
  final String locale;
  final String sampleRateHertz;
  final String voiceType;
  final String status;
  final List<VoiceStyle> styles;
  final List<VoiceRole> roles;

  factory Voice.fromJson(Map<String, dynamic> json) {
    return _$VoiceFromJson(json);
  }

  Voice(
      {required this.name,
      required this.displayName,
      required this.localName,
      required this.shortName,
      required this.gender,
      required this.locale,
      required this.sampleRateHertz,
      required this.voiceType,
      required this.status,
      required this.styles,
      required this.roles});

  Map<String, dynamic> toJson() => _$VoiceToJson(this);
}

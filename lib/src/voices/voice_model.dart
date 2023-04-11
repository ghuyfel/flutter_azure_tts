import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'voice_model.g.dart';

@JsonSerializable()
class Voice extends Equatable {
  @JsonKey(name: "Name")
  final String name;
  @JsonKey(name: "DisplayName")
  final String displayName;
  @JsonKey(name: "LocalName")
  final String localName;
  @JsonKey(name: "ShortName")
  final String shortName;
  @JsonKey(name: "Gender")
  final String gender;
  @JsonKey(name: "Locale")
  final String locale;
  @JsonKey(name: "SampleRateHertz")
  final String sampleRateHertz;
  @JsonKey(name: "VoiceType")
  final String voiceType;
  @JsonKey(name: "Status")
  final String status;

  Voice(
      {required this.name,
      required this.displayName,
      required this.localName,
      required this.shortName,
      required this.gender,
      required this.locale,
      required this.sampleRateHertz,
      required this.voiceType,
      required this.status});

  factory Voice.fromJson(Map<String, dynamic> json) => _$VoiceFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceToJson(this);

  @override
  List<Object?> get props => [
        name,
        displayName,
        localName,
        shortName,
        gender,
        locale,
        sampleRateHertz,
        voiceType,
        status
      ];
}

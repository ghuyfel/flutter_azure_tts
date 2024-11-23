import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'voice_data.g.dart';

@JsonSerializable()
class VoiceData extends Equatable {
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
  @JsonKey(name: "StyleList")
  final List<String>? styles;
  @JsonKey(name: "RolePlayList")
  final List<String>? roles;

  const VoiceData({
    required this.name,
    required this.displayName,
    required this.localName,
    required this.shortName,
    required this.gender,
    required this.locale,
    required this.sampleRateHertz,
    required this.voiceType,
    required this.status,
    this.styles,
    this.roles,
  });

  factory VoiceData.fromJson(Map<String, dynamic> json) => _$VoiceDataFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceDataToJson(this);

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
    status,
    styles,
    roles,
  ];
}
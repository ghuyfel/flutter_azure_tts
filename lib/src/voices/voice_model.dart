import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'voice_model.g.dart';

@JsonSerializable()
class Voice extends Equatable {
  @JsonKey(name: "Name")
  final String name;
  @JsonKey(name: "DisplayName")
  String displayName;
  @JsonKey(name: "LocalName")
  String localName;
  @JsonKey(name: "ShortName")
  String shortName;
  @JsonKey(name: "Gender")
  String gender;
  @JsonKey(name: "Locale")
  String locale;
  @JsonKey(name: "SampleRateHertz")
  String sampleRateHertz;
  @JsonKey(name: "VoiceType")
  String voiceType;
  @JsonKey(name: "Status")
  String status;

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
  List<Object?> get props => [name, displayName, localName, shortName, gender, locale, sampleRateHertz, voiceType, status];

}

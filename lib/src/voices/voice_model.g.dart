// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Voice _$VoiceFromJson(Map<String, dynamic> json) => Voice(
      name: json['Name'] as String,
      displayName: json['DisplayName'] as String,
      localName: json['LocalName'] as String,
      shortName: json['ShortName'] as String,
      gender: json['Gender'] as String,
      locale: json['Locale'] as String,
      sampleRateHertz: json['SampleRateHertz'] as String,
      voiceType: json['VoiceType'] as String,
      status: json['Status'] as String,
      styles: (json['StyleList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      roles: (json['RolePlayList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$VoiceToJson(Voice instance) => <String, dynamic>{
      'Name': instance.name,
      'DisplayName': instance.displayName,
      'LocalName': instance.localName,
      'ShortName': instance.shortName,
      'Gender': instance.gender,
      'Locale': instance.locale,
      'SampleRateHertz': instance.sampleRateHertz,
      'VoiceType': instance.voiceType,
      'Status': instance.status,
      'StyleList': instance.styles,
      'RolePlayList': instance.roles,
    };

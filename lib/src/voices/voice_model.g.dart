// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Voice _$VoiceFromJson(Map<String, dynamic> json) => Voice(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      localName: json['localName'] as String,
      shortName: json['shortName'] as String,
      gender: json['gender'] as String,
      locale: json['locale'] as String,
      sampleRateHertz: json['sampleRateHertz'] as String,
      voiceType: json['voiceType'] as String,
      status: json['status'] as String,
      styles: (json['styles'] as List<dynamic>?)
          !.map((e) => $enumDecode(_$VoiceStyleEnumMap, e))
          .toList(),
      roles: (json['roles'] as List<dynamic>?)
          !.map((e) => $enumDecode(_$VoiceRoleEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$VoiceToJson(Voice instance) => <String, dynamic>{
      'name': instance.name,
      'displayName': instance.displayName,
      'localName': instance.localName,
      'shortName': instance.shortName,
      'gender': instance.gender,
      'locale': instance.locale,
      'sampleRateHertz': instance.sampleRateHertz,
      'voiceType': instance.voiceType,
      'status': instance.status,
      'styles': instance.styles.map((e) => _$VoiceStyleEnumMap[e]!).toList(),
      'roles': instance.roles.map((e) => _$VoiceRoleEnumMap[e]!).toList(),
    };

const _$VoiceStyleEnumMap = {
  VoiceStyle.advertisement_upbeat: 'advertisement_upbeat',
  VoiceStyle.affectionate: 'affectionate',
  VoiceStyle.assistant: 'assistant',
  VoiceStyle.calm: 'calm',
  VoiceStyle.chat: 'chat',
  VoiceStyle.cheerful: 'cheerful',
  VoiceStyle.customerservice: 'customerservice',
  VoiceStyle.depressed: 'depressed',
  VoiceStyle.disgruntled: 'disgruntled',
  VoiceStyle.documentary_narration: 'documentary_narration',
  VoiceStyle.embarrassed: 'embarrassed',
  VoiceStyle.empathetic: 'empathetic',
  VoiceStyle.envious: 'envious',
  VoiceStyle.excited: 'excited',
  VoiceStyle.fearful: 'fearful',
  VoiceStyle.friendly: 'friendly',
  VoiceStyle.gentle: 'gentle',
  VoiceStyle.hopeful: 'hopeful',
  VoiceStyle.lyrical: 'lyrical',
  VoiceStyle.narration_professional: 'narration_professional',
  VoiceStyle.narration_relaxed: 'narration_relaxed',
  VoiceStyle.newscast: 'newscast',
  VoiceStyle.newscast_casual: 'newscast_casual',
  VoiceStyle.newscast_formal: 'newscast_formal',
  VoiceStyle.poetry_reading: 'poetry_reading',
  VoiceStyle.sad: 'sad',
  VoiceStyle.serious: 'serious',
  VoiceStyle.shouting: 'shouting',
  VoiceStyle.sports_commentary: 'sports_commentary',
  VoiceStyle.sports_commentary_excited: 'sports_commentary_excited',
  VoiceStyle.whispering: 'whispering',
  VoiceStyle.terrified: 'terrified',
  VoiceStyle.unfriendly: 'unfriendly',
};

const _$VoiceRoleEnumMap = {
  VoiceRole.Girl: 'Girl',
  VoiceRole.Boy: 'Boy',
  VoiceRole.YoungAdultFemale: 'YoungAdultFemale',
  VoiceRole.YoungAdultMale: 'YoungAdultMale',
  VoiceRole.OlderAdultFemale: 'OlderAdultFemale',
  VoiceRole.OlderAdultMale: 'OlderAdultMale',
  VoiceRole.SeniorFemale: 'SeniorFemale',
  VoiceRole.SeniorMale: 'SeniorMale',
};

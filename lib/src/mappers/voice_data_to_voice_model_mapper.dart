import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:flutter_azure_tts/src/voices/voice_data.dart';

import 'mapper_interface.dart';

class VoiceDataToVoiceModelMapper implements Mapper<VoiceData, Voice> {
  @override
  Voice toModel(VoiceData entity) {
    final roles = <VoiceRole>[];
    final styles = <VoiceStyle>[];

    if (entity.roles != null) {
      for (String roleString in entity.roles!) {
        final role = _getRoleEnumFromString(roleString);
        if (role == null) {
          continue;
        } else {
          roles.add(role);
        }
      }
    }

    if (entity.styles != null) {
      for (String styleString in entity.styles!) {
        final style = _getStyleFromString(styleString);
        if (style == null) {
          continue;
        } else {
          styles.add(style);
        }
      }
    }

    return Voice(
        name: entity.name,
        displayName: entity.displayName,
        localName: entity.localName,
        shortName: entity.shortName,
        gender: entity.gender,
        locale: entity.locale,
        sampleRateHertz: entity.sampleRateHertz,
        voiceType: entity.voiceType,
        status: entity.status,
        styles: styles,
        roles: roles);
  }

  @override
  List<Voice> toModelList(List<VoiceData> entities) {
    return entities.map((e) => toModel(e)).toList(growable: false);
  }

  VoiceRole? _getRoleEnumFromString(String r) {
    for (VoiceRole role in VoiceRole.values) {
      if (role.name.toLowerCase().compareTo(r.toLowerCase()) == 0) {
        return role;
      }
    }
    return null;
  }

  VoiceStyle? _getStyleFromString(String s) {
    for (VoiceStyle style in VoiceStyle.values) {
      if (style.styleName.compareTo(s) == 0) {
        return style;
      }
    }
    return null;
  }
}

import 'package:azure_tts/src/common/base_header.dart';

class AudioTypeHeader extends BaseHeader {
  ///Audio format should be selected from [AudioOutputFormat] class.
  AudioTypeHeader({required String audioFormat})
      : super(type: "X-Microsoft-OutputFormat", value: audioFormat);

  @override
  String get headerValue => value;
}

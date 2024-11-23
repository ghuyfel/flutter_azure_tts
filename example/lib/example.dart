// Generate with a random German voice: example.dart -v de- -t 'Hallo, wie gehts?'
// List all English voices with style options: example.dart -v en- -l -x
// Generate two audio files with different styles: example.dart -v en- -s shouting,whispering
// Generate four audio files with various levels of excitement: example.dart -s excited -d 0.01,0.5,1.0,2.0
import 'dart:io';
import 'dart:typed_data';
import 'package:args/args.dart';
import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:flutter_azure_tts/src/ssml/style_ssml.dart';

// You can also pass these with -k and -e
const _azureKey = 'YOUR SUBSCRIPTION KEY';
const _azureRegion = 'YOUR REGION';

final _parser = ArgParser()
  ..addFlag(
    'help',
    abbr: 'h',
    help: 'Show this help message.',
    negatable: false,
  )
  ..addOption(
    'text',
    abbr: 't',
    defaultsTo: 'Microsoft Speech Service Text-to-Speech API is awesome',
    help: 'The text to speak.',
  )
  ..addOption(
    'voice',
    abbr: 'v',
    defaultsTo: 'en-',
    help: 'The voice to use. It is acceptable to supply an ambiguous argument. '
        'e.g. \'en-\' will cause a random English voice to be picked.',
  )
  ..addFlag(
    'listvoices',
    abbr: 'l',
    help: 'All voices matching the voice argument will be displayed.',
  )
  ..addOption(
    'styles',
    abbr: 's',
    help: 'An optional, comma-delimited list of styles to generate audio for. '
        'e.g. \'cheerful,sad\'; don\'t use spaces.',
  )
  ..addOption(
    'styledegrees',
    abbr: 'd',
    help: 'The degree to which to apply the style. '
        'An optional, comma-delimited list of style degrees '
        'e.g. \'1.5\', or \'0.5,0.8\'; don\'t use spaces.',
  )
  ..addOption(
    'outprefix',
    abbr: 'o',
    help: 'A prefix that will be applied to output file names.',
  )
  ..addOption(
    'rate',
    abbr: 'r',
    defaultsTo: '1.0',
    help: 'Prosody rate, 1.0 is normal.',
  )
  ..addFlag(
    'onlystyles',
    abbr: 'x',
    help: 'Filters out voices that don\'t havev any styles. '
        'Useful when combined with -l for finding voices.',
  )
  ..addOption(
    'key',
    abbr: 'k',
    help: 'Your Azure key',
  )
  ..addOption(
    'region',
    abbr: 'e',
    help: 'Your Azure region',
  );

void main(List<String> argss) async {
  final args = _parser.parse(argss);
  if (args['help']) {
    print(_parser.usage);
    return;
  }

  AzureTts.init(
    subscriptionKey: args['key'] ?? _azureKey,
    region: args['region'] ?? _azureRegion,
    withLogs: true,
  );

  // Get available voices
  final voicesResponse = await AzureTts.getAvailableVoices();
  List<Voice> voices = voicesResponse.voices
      .where((e) =>
          e.shortName.toLowerCase().contains(args['voice'].toLowerCase()))
      .toList();
  voices.shuffle();

  if (args['onlystyles']) {
    voices.removeWhere((e) => e.styles.isEmpty);
  }

  List<String?> styles = args['styles']?.split(',') ?? [null];
  bool hasStyles = styles.isNotEmpty && styles.first != null;
  if (hasStyles) {
    for (final style in styles) {
      voices.removeWhere((e) => !e.styles.contains(style));
    }
  }
  List<double?> styleDegrees = args['styledegrees']
          ?.split(',')
          .map<double>((e) => double.parse(e))
          .toList() ??
      [null];

  if (voices.isEmpty) {
    print(
      'No voice found matching \'${args['voice']}\''
      '${hasStyles ? ' with styles $styles' : ''}',
    );
    exit(0);
  }

  if (args['listvoices']) {
    print(' --- Voices matching \'${args['voice']}\' (${voices.length}) --- ');
    print(
        voices.map((e) => '${e.shortName} || roles:  ${e.roles} || styles: ${e.styles}').join('\n'));
    print(' ------ ');

    exit(0);
  }

  final voice = voices.first;
  print('Using voice ${voice.shortName} (styles: ${voice.styles})');

  List<Future> futures = [];
  for (final style in styles) {
    for (final degree in styleDegrees) {
      final f = _generateTtsAudio(
              voice: voice,
              text: args['text'],
              rate: double.parse(args['rate']),
              style: style,
              degree: degree)
          .then((data) => _writeFile(
                '${args['outprefix'] ?? ''}${voice.shortName}'
                '${style != null ? '_$style' : ''}'
                '${degree != null ? '_$degree' : ''}.mp3',
                data,
              ));
      futures.add(f);
    }
  }
  await Future.wait(futures);
  print('Done!');
  exit(0); // something doesn't get disposed properly, should investigate
}

Future<Uint8List> _generateTtsAudio({
  required Voice voice,
  required String text,
  double rate = 1.0,
  String? style,
  double? degree,
}) async {
  TtsParams params = TtsParams(
    voice: voice,
    audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3,
    rate: rate,
    // optional prosody rate (default is 1.0)
    text: text,
    style: StyleSsml(
        style: VoiceStyle.values
            .where((e) => e.name.compareTo(style ?? "") == 0)
            .first,
    styleDegree: degree ?? 1,),
  );
  final ttsResponse = await AzureTts.getTts(params);
  print('Generated audio for voice ${voice.shortName} with style $style'
      ', degree $degree');
  return ttsResponse.audio;
}

void _writeFile(String filename, Uint8List data) {
  final file = File(filename);
  file.writeAsBytesSync(data);
  print(
      'Wrote ${(data.lengthInBytes / 1024).toStringAsFixed(2)}kb to file $filename');
}

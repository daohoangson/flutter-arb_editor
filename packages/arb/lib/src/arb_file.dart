import 'dart:convert';
import 'dart:io';

import 'package:intl_translation/src/intl_message.dart';
import 'package:path/path.dart' show basenameWithoutExtension;

import 'internal/icu.dart';
import 'message.dart';

const _jsonDecoder = JsonCodec();

class ArbFile {
  final bool isOriginal;
  final DateTime lastModified;
  final String locale;
  final List<ArbTranslation> translations;

  ArbFile({
    this.isOriginal = false,
    this.lastModified,
    this.locale,
    this.translations,
  });

  factory ArbFile.fromContents(String contents, [String path]) {
    var data = _jsonDecoder.decode(contents) as Map<String, dynamic>;

    var isOriginal = false;
    DateTime lastModified;
    String locale;
    final strings = <String, ArbString>{};
    final translations = <String, ArbTranslation>{};

    for (final entry in data.entries) {
      switch (entry.key) {
        case '@@last_modified':
          final dateTime = DateTime.tryParse(entry.value);
          if (dateTime != null) {
            lastModified = dateTime;
          }
          break;
        case '@@locale':
        case '_locale':
          locale = entry.value;
          break;
        default:
          if (entry.key.startsWith('@')) {
            // metadata
            if (entry.value is Map) {
              final main = MainMessage();
              main.arguments = [];
              main.description = entry.value['description'];
              main.examples = {};
              main.name = entry.key.substring(1);

              final placeholders = entry.value['placeholders'];
              if (placeholders is Map) {
                for (final placeholder in placeholders.entries) {
                  final arg = placeholder.key;
                  final example = placeholder.value['example'];

                  main.arguments.add(arg);
                  main.examples[arg] = example;
                }
              }

              strings[main.name] = ArbString(main);
            }
          } else {
            // translation
            final translated = fromIcuForm(entry.value);
            translations[entry.key] = ArbTranslation(translated);
          }
      }
    }

    if (locale == null && path != null) {
      if (path.endsWith('_messages.arb')) {
        isOriginal = true;
      } else {
        var name = basenameWithoutExtension(path);
        locale = name.split('_').skip(1).join('_');
      }
    }

    for (final translation in translations.entries) {
      final string = strings[translation.key];
      if (string == null) continue;

      if (isOriginal) {
        string.original = translation.value;
      } else if (locale != null) {
        string[locale] = translation.value;
      }
    }

    return ArbFile(
      isOriginal: isOriginal,
      lastModified: lastModified,
      locale: locale,
      translations: translations.values.toList(growable: false),
    );
  }

  static Future<ArbFile> fromFile(File file) => file
      .readAsString()
      .then((contents) => ArbFile.fromContents(contents, file.path));
}

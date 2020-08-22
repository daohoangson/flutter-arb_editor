import 'dart:convert';
import 'dart:io';

import 'package:intl_translation/src/icu_parser.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:path/path.dart' show basenameWithoutExtension;

import 'icu_form.dart';

const _jsonDecoder = JsonCodec();
final _pluralAndGenderParser = IcuParser().message;
final _plainParser = IcuParser().nonIcuMessage;

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
    final translations = <ArbTranslation>[];

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
            Message parsed = _pluralAndGenderParser.parse(entry.value).value;
            if (parsed is LiteralString && parsed.string.isEmpty) {
              parsed = _plainParser.parse(entry.value).value;
            }
            translations.add(ArbTranslation(strings, entry.key, parsed));
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

    for (final translation in translations) {
      final string = translation.string;
      if (string != null) {
        if (isOriginal) {
          string._original = translation;
        } else if (locale != null) {
          string[locale] = translation;
        }
      }
    }

    return ArbFile(
      isOriginal: isOriginal,
      lastModified: lastModified,
      locale: locale,
      translations: translations,
    );
  }

  static Future<ArbFile> fromFile(File file) => file
      .readAsString()
      .then((contents) => ArbFile.fromContents(contents, file.path));
}

class ArbString {
  final MainMessage _main;
  final List<ArbTranslation> _originals = [];
  final Map<String, ArbTranslation> _translations = {};

  ArbString(this._main);

  String get description => _main.description;

  int get length => _translations.length;

  Iterable<String> get locales => _translations.keys;

  String get name => _main.name;

  ArbTranslation get original => _originals.length == 1 ? _originals[0] : null;
  set _original(ArbTranslation original) {
    _originals.clear();
    _originals.add(original);
    original._translated.parent = _main;
  }

  Iterable<ArbTranslation> get translations => _translations.values;

  ArbTranslation operator [](String locale) => _translations[locale];

  operator []=(String locale, ArbTranslation translation) {
    _translations[locale] = translation;
    translation._translated.parent = _main;
  }

  @override
  String toString() => _main.toString();
}

class ArbTranslation {
  final String name;
  final Message _translated;

  final Map<String, ArbString> _strings;

  ArbString _string;

  ArbTranslation(this._strings, this.name, this._translated);

  ArbString get string => _string ?? _strings[name];
  set string(ArbString v) => _string = v;

  @override
  String toString() => _translated.toIcuForm();
}

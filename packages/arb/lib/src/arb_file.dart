import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl_translation/generate_localized.dart';
import 'package:intl_translation/src/icu_parser.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:path/path.dart' show basenameWithoutExtension;

const _jsonDecoder = JsonCodec();
final _pluralAndGenderParser = IcuParser().message;
final _plainParser = IcuParser().nonIcuMessage;

@immutable
class ArbFile {
  final DateTime lastModified;
  final String locale;
  final List<ArbMessage> messages;

  ArbFile({
    this.lastModified,
    this.locale,
    this.messages,
  });

  factory ArbFile.fromContents(String contents, [String path]) {
    var data = _jsonDecoder.decode(contents) as Map<String, dynamic>;

    DateTime lastModified;
    String locale;
    final metadata = <String, MainMessage>{};
    final messages = <ArbMessage>[];

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
              final message = MainMessage();
              message.arguments = [];
              message.description = entry.value['description'];
              message.examples = {};
              message.name = entry.key.substring(1);

              final placeholders = entry.value['placeholders'];
              if (placeholders is Map) {
                for (final placeholder in placeholders.entries) {
                  final arg = placeholder.key;
                  final example = placeholder.value['example'];

                  message.arguments.add(arg);
                  message.examples[arg] = example;
                }
              }

              metadata[message.name] = message;
            }
          } else {
            // translation
            Message parsed = _pluralAndGenderParser.parse(entry.value).value;
            if (parsed is LiteralString && parsed.string.isEmpty) {
              parsed = _plainParser.parse(entry.value).value;
            }
            messages.add(ArbMessage(metadata, entry.key, parsed));
          }
      }
    }

    if (locale == null && path != null) {
      var name = basenameWithoutExtension(path);
      locale = name.split('_').skip(1).join('_');
    }

    locale ??= '';

    for (final message in messages) {
      message.metadata?.addTranslation(locale, message.message);
    }

    return ArbFile(
      lastModified: lastModified,
      locale: locale,
      messages: messages,
    );
  }

  static Future<ArbFile> fromFile(File file) => file
      .readAsString()
      .then((contents) => ArbFile.fromContents(contents, file.path));
}

class ArbMessage extends TranslatedMessage {
  final Map<String, MainMessage> _metadata;

  ArbMessage(this._metadata, String name, Message translated)
      : super(name, translated);

  MainMessage get metadata => _metadata[id];
}

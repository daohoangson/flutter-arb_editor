import 'package:intl_translation/src/icu_parser.dart';
import 'package:intl_translation/src/intl_message.dart';

final _pluralAndGenderParser = IcuParser().message;
final _plainParser = IcuParser().nonIcuMessage;

Message fromIcuForm(String input) {
  Message parsed = _pluralAndGenderParser.parse(input).value;
  if (parsed is LiteralString && parsed.string.isEmpty) {
    parsed = _plainParser.parse(input).value;
  }

  return parsed;
}

String toIcuForm(Message message) => message.expanded(_toIcuForm);

String _toIcuForm(Message message, chunk, {bool shouldEscapeICU = false}) {
  if (chunk is String) {
    return shouldEscapeICU ? _escape(chunk) : chunk;
  }
  if (chunk is int && chunk >= 0 && chunk < message.arguments.length) {
    return '{${message.arguments[chunk]}}';
  }
  if (chunk is SubMessage) {
    return chunk.expanded(
        (message, chunk) => _toIcuForm(message, chunk, shouldEscapeICU: true));
  }
  if (chunk is Message) {
    return chunk.expanded((message, chunk) =>
        _toIcuForm(message, chunk, shouldEscapeICU: shouldEscapeICU));
  }
  throw FormatException('Illegal interpolation: $chunk');
}

String _escape(String s) =>
    s.replaceAll("'", "''").replaceAll('{', "'{'").replaceAll('}', "'}'");

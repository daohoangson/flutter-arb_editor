import 'package:intl_translation/src/intl_message.dart';

extension IcuForm on Message {
  String toIcuForm() => expanded(_f);
}

String _f(Message message, chunk, {bool shouldEscapeICU = false}) {
  if (chunk is String) {
    return shouldEscapeICU ? _escape(chunk) : chunk;
  }
  if (chunk is int && chunk >= 0 && chunk < message.arguments.length) {
    return '{${message.arguments[chunk]}}';
  }
  if (chunk is SubMessage) {
    return chunk.expanded(
        (message, chunk) => _f(message, chunk, shouldEscapeICU: true));
  }
  if (chunk is Message) {
    return chunk.expanded((message, chunk) =>
        _f(message, chunk, shouldEscapeICU: shouldEscapeICU));
  }
  throw FormatException('Illegal interpolation: $chunk');
}

String _escape(String s) =>
    s.replaceAll("'", "''").replaceAll('{', "'{'").replaceAll('}', "'}'");

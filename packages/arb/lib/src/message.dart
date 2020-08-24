import 'package:intl_translation/src/intl_message.dart';

import 'internal/icu.dart';

class ArbString {
  final MainMessage _main;
  final Map<String, ArbTranslation> _translations = {};

  ArbTranslation _original;

  ArbString(this._main);

  List<String> get arguments => _main.arguments;

  Map<String, dynamic> get example => _main.examples;

  String get description => _main.description;

  int get length => _translations.length;

  Iterable<String> get locales => _translations.keys;

  String get name => _main.name;

  ArbTranslation get original => _original;
  set original(ArbTranslation original) {
    _original = original;

    // this must match `operator []=` below
    original._string = this;
    original._translated.parent = _main;
  }

  Iterable<ArbTranslation> get translations => _translations.values;

  ArbTranslation operator [](String locale) => _translations[locale];

  operator []=(String locale, ArbTranslation translation) {
    _translations[locale] = translation;

    // this must match `original=` above
    translation._string = this;
    translation._translated.parent = _main;
  }

  @override
  String toString() => _main.toString();
}

class ArbTranslation {
  ArbString _string;
  Message _translated;

  ArbTranslation(this._translated);

  factory ArbTranslation.fromIcuForm(String input) =>
      ArbTranslation(fromIcuForm(input));

  ArbString get string => _string;

  @override
  String toString() => toIcuForm(_translated);

  void update(String icuForm) {
    final parsed = fromIcuForm(icuForm);
    parsed.parent = _translated.parent;

    // try expanding to catch invalid update
    parsed.expanded();

    _translated = parsed;
  }
}

import 'dart:io';

import 'package:arb/arb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_translation/src/intl_message.dart';

void main() {
  group('ArbProject', () {
    test('merges metadata', () {
      final enString = ArbString(MainMessage()..name = 'foo');
      final enStrings = {enString.name: enString};
      final enTranslation =
          ArbTranslation(enStrings, enString.name, LiteralString('bar', null));
      enString['en'] = enTranslation;
      final enFile = ArbFile(locale: 'en', translations: [enTranslation]);
      expect(enString.length, equals(1));

      final viString = ArbString(MainMessage()..name = 'foo');
      final viStrings = {viString.name: viString};
      final viTranslation = ArbTranslation(
          viStrings, viString.name, LiteralString('barrrr', null));
      viString['vi'] = viTranslation;
      final viFile = ArbFile(locale: 'vi', translations: [viTranslation]);
      expect(viString.length, equals(1));

      final arbProject = ArbProject.fromFile([enFile, viFile]);
      expect(arbProject.files.length, equals(2));
      expect(arbProject.length, equals(1));

      final string = arbProject['foo'];
      expect(string.length, equals(2));
      expect(string['en'].toCode(), equals('bar'));
      expect(string['vi'].toCode(), equals('barrrr'));
    });
  });

  test('parses directory', () async {
    final arbProject = await ArbProject.fromDirectory(Directory('./intl'));
    expect(arbProject.errors, isEmpty);
    expect(arbProject.files.length, equals(3));
    expect(arbProject.length, equals(8));
    expect(arbProject.localeDefault, equals('en'));

    final _expect = (String name, {String en, String vi}) {
      final string = arbProject[name];
      expect(string.original.toCode(), equals(en));
      expect(string['en'].toCode(), equals(en));
      expect(string['vi'].toCode(), equals(vi));
    };

    _expect('message', en: 'message', vi: 'nội dung');

    _expect('messageWithArg', en: r'arg=${arg}', vi: r'tham số=${arg}');

    _expect(
      'gender',
      en: r'${Intl.gender(gender, '
          r"female: 'gender=female', "
          r"male: 'gender=male', "
          r"other: 'gender=other'"
          ')}',
      vi: r'${Intl.gender(gender, '
          r"female: 'gender=nữ', "
          r"male: 'gender=nam', "
          r"other: 'gender=khác'"
          ')}',
    );

    _expect(
      'genderWithArg',
      en: r'${Intl.gender(gender, '
          r"female: 'gender=female arg=${arg}', "
          r"male: 'gender=male arg=${arg}', "
          r"other: 'gender=other arg=${arg}'"
          ')}',
      vi: r'${Intl.gender(gender, '
          r"female: 'gender=nữ tham số=${arg}', "
          r"male: 'gender=nam tham số=${arg}', "
          r"other: 'gender=khác tham số=${arg}'"
          ')}',
    );

    _expect(
      'plural',
      en: r'${Intl.plural(n, '
          r"zero: 'n=zero', "
          r"one: 'n=one', "
          r"two: 'n=two', "
          r"few: 'n=few', "
          r"many: 'n=many', "
          r"other: 'n=other'"
          ')}',
      vi: r'${Intl.plural(n, '
          r"zero: 'n=không', "
          r"one: 'n=một', "
          r"two: 'n=hai', "
          r"few: 'n=một vài', "
          r"many: 'n=nhiều', "
          r"other: 'n=khác'"
          ')}',
    );

    _expect(
      'pluralWithArg',
      en: r'${Intl.plural(n, '
          r"zero: 'n=zero arg=${arg}', "
          r"one: 'n=one arg=${arg}', "
          r"two: 'n=two arg=${arg}', "
          r"few: 'n=few arg=${arg}', "
          r"many: 'n=many arg=${arg}', "
          r"other: 'n=other arg=${arg}'"
          ')}',
      vi: r'${Intl.plural(n, '
          r"zero: 'n=không tham số=${arg}', "
          r"one: 'n=một tham số=${arg}', "
          r"two: 'n=hai tham số=${arg}', "
          r"few: 'n=một vài tham số=${arg}', "
          r"many: 'n=nhiều tham số=${arg}', "
          r"other: 'n=khác tham số=${arg}'"
          ')}',
    );

    _expect(
      'select',
      en: r'${Intl.select(choice, {'
          r"'foo': 'choice=foo', "
          r"'bar': 'choice=bar', "
          '})}',
      vi: r'${Intl.select(choice, {'
          r"'foo': 'chọn=foo', "
          r"'bar': 'chọn=bar', "
          '})}',
    );

    _expect(
      'selectWithArg',
      en: r'${Intl.select(choice, {'
          r"'foo': 'choice=foo arg=${arg}', "
          r"'bar': 'choice=bar arg=${arg}', "
          '})}',
      vi: r'${Intl.select(choice, {'
          r"'foo': 'chọn=foo tham số=${arg}', "
          r"'bar': 'chọn=bar tham số=${arg}', "
          '})}',
    );
  });
}

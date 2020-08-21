import 'dart:io';

import 'package:arb/arb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_translation/src/intl_message.dart';

void main() {
  group('ArbProject', () {
    test('merges metadata', () {
      final enFoo = MainMessage()..name = 'foo';
      final enMetadata = <String, MainMessage>{enFoo.name: enFoo};
      final enMessageFoo =
          ArbMessage(enMetadata, enFoo.name, LiteralString('bar', null));
      enFoo.addTranslation('en', enMessageFoo.translated);
      final enFile = ArbFile(locale: 'en', messages: [enMessageFoo]);
      expect(enFoo.translations['en'], equals('bar'));

      final viFoo = MainMessage()..name = 'foo';
      final viMetadata = <String, MainMessage>{viFoo.name: viFoo};
      final viMessageFoo =
          ArbMessage(viMetadata, viFoo.name, LiteralString('barrrr', null));
      viFoo.addTranslation('vi', viMessageFoo.translated);
      final viFile = ArbFile(locale: 'vi', messages: [viMessageFoo]);
      expect(viFoo.translations['vi'], equals('barrrr'));

      final arbProject = ArbProject([enFile, viFile]);
      expect(arbProject.files.length, equals(2));
      expect(arbProject.metadata.entries.length, equals(1));

      final metadata = arbProject.metadata['foo'];
      expect(metadata.translations['en'], equals('bar'));
      expect(metadata.translations['vi'], equals('barrrr'));
    });
  });

  test('parses directory', () async {
    final arbProject = await ArbProject.fromDirectory(Directory('./intl'));
    expect(arbProject.errors, isEmpty);
    expect(arbProject.files.length, equals(2));
    expect(arbProject.metadata.entries.length, equals(8));

    final m = arbProject.metadata;

    expect(m['message'].translations['en'], equals('message'));
    expect(m['message'].translations['vi'], equals('nội dung'));

    expect(m['messageWithArg'].translations['en'], equals(r'arg=${arg}'));
    expect(m['messageWithArg'].translations['vi'], equals(r'tham số=${arg}'));

    expect(
        m['gender'].translations['en'],
        equals(r'${Intl.gender(gender, '
            r"female: 'gender=female', "
            r"male: 'gender=male', "
            r"other: 'gender=other'"
            ')}'));
    expect(
        m['gender'].translations['vi'],
        equals(r'${Intl.gender(gender, '
            r"female: 'gender=nữ', "
            r"male: 'gender=nam', "
            r"other: 'gender=khác'"
            ')}'));

    expect(
        m['genderWithArg'].translations['en'],
        equals(r'${Intl.gender(gender, '
            r"female: 'gender=female arg=${arg}', "
            r"male: 'gender=male arg=${arg}', "
            r"other: 'gender=other arg=${arg}'"
            ')}'));
    expect(
        m['genderWithArg'].translations['vi'],
        equals(r'${Intl.gender(gender, '
            r"female: 'gender=nữ tham số=${arg}', "
            r"male: 'gender=nam tham số=${arg}', "
            r"other: 'gender=khác tham số=${arg}'"
            ')}'));

    expect(
        m['plural'].translations['en'],
        equals(r'${Intl.plural(n, '
            r"zero: 'n=zero', "
            r"one: 'n=one', "
            r"two: 'n=two', "
            r"few: 'n=few', "
            r"many: 'n=many', "
            r"other: 'n=other'"
            ')}'));
    expect(
        m['plural'].translations['vi'],
        equals(r'${Intl.plural(n, '
            r"zero: 'n=không', "
            r"one: 'n=một', "
            r"two: 'n=hai', "
            r"few: 'n=một vài', "
            r"many: 'n=nhiều', "
            r"other: 'n=khác'"
            ')}'));

    expect(
        m['pluralWithArg'].translations['en'],
        equals(r'${Intl.plural(n, '
            r"zero: 'n=zero arg=${arg}', "
            r"one: 'n=one arg=${arg}', "
            r"two: 'n=two arg=${arg}', "
            r"few: 'n=few arg=${arg}', "
            r"many: 'n=many arg=${arg}', "
            r"other: 'n=other arg=${arg}'"
            ')}'));
    expect(
        m['pluralWithArg'].translations['vi'],
        equals(r'${Intl.plural(n, '
            r"zero: 'n=không tham số=${arg}', "
            r"one: 'n=một tham số=${arg}', "
            r"two: 'n=hai tham số=${arg}', "
            r"few: 'n=một vài tham số=${arg}', "
            r"many: 'n=nhiều tham số=${arg}', "
            r"other: 'n=khác tham số=${arg}'"
            ')}'));

    expect(
        m['select'].translations['en'],
        equals(r'${Intl.select(choice, {'
            r"'foo': 'choice=foo', "
            r"'bar': 'choice=bar', "
            '})}'));
    expect(
        m['select'].translations['vi'],
        equals(r'${Intl.select(choice, {'
            r"'foo': 'chọn=foo', "
            r"'bar': 'chọn=bar', "
            '})}'));

    expect(
        m['selectWithArg'].translations['en'],
        equals(r'${Intl.select(choice, {'
            r"'foo': 'choice=foo arg=${arg}', "
            r"'bar': 'choice=bar arg=${arg}', "
            '})}'));
    expect(
        m['selectWithArg'].translations['vi'],
        equals(r'${Intl.select(choice, {'
            r"'foo': 'chọn=foo tham số=${arg}', "
            r"'bar': 'chọn=bar tham số=${arg}', "
            '})}'));
  });
}

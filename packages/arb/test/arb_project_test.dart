import 'dart:io';

import 'package:arb/arb.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:test/test.dart';

void main() {
  group('ArbProject', () {
    test('merges metadata', () {
      final enString = ArbString(MainMessage()..name = 'foo');
      final enTranslation = ArbTranslation.fromIcuForm('bar');
      enString['en'] = enTranslation;
      final enFile = ArbFile(locale: 'en', translations: [enTranslation]);
      expect(enString.length, equals(1));

      final viString = ArbString(MainMessage()..name = 'foo');
      final viTranslation = ArbTranslation.fromIcuForm('barrrr');
      viString['vi'] = viTranslation;
      final viFile = ArbFile(locale: 'vi', translations: [viTranslation]);
      expect(viString.length, equals(1));

      final arbProject = ArbProject.fromFile([enFile, viFile]);
      expect(arbProject.files.length, equals(2));
      expect(arbProject.strings.length, equals(1));

      final string = arbProject.strings[0];
      expect(string.length, equals(2));
      expect("${string['en']}", equals('bar'));
      expect("${string['vi']}", equals('barrrr'));
    });
  });

  test('parses directory', () async {
    final arbProject = await ArbProject.fromDirectory(Directory('./intl'));
    expect(arbProject.errors, isEmpty);
    expect(arbProject.files.length, equals(3));
    expect(arbProject.strings.length, equals(8));

    final _expect = (String name, {String en, String vi}) {
      final string = arbProject.getStringByName(name);
      expect('${string.original}', equals(en));
      expect("${string['en']}", equals(en));
      expect("${string['vi']}", equals(vi));
    };

    _expect('message', en: 'message', vi: 'nội dung');

    _expect('messageWithArg', en: r'arg={arg}', vi: r'tham số={arg}');

    _expect(
      'gender',
      en: '{gender,select, female{gender=female}male{gender=male}other{gender=other}}',
      vi: '{gender,select, female{gender=nữ}male{gender=nam}other{gender=khác}}',
    );

    _expect(
      'genderWithArg',
      en: '{gender,select, female{gender=female arg={arg}}male{gender=male arg={arg}}other{gender=other arg={arg}}}',
      vi: '{gender,select, female{gender=nữ tham số={arg}}male{gender=nam tham số={arg}}other{gender=khác tham số={arg}}}',
    );

    _expect(
      'plural',
      en: '{n,plural, =0{n=zero}=1{n=one}=2{n=two}few{n=few}many{n=many}other{n=other}}',
      vi: '{n,plural, =0{n=không}=1{n=một}=2{n=hai}few{n=một vài}many{n=nhiều}other{n=khác}}',
    );

    _expect(
      'pluralWithArg',
      en: '{n,plural, =0{n=zero arg={arg}}=1{n=one arg={arg}}=2{n=two arg={arg}}few{n=few arg={arg}}many{n=many arg={arg}}other{n=other arg={arg}}}',
      vi: '{n,plural, =0{n=không tham số={arg}}=1{n=một tham số={arg}}=2{n=hai tham số={arg}}few{n=một vài tham số={arg}}many{n=nhiều tham số={arg}}other{n=khác tham số={arg}}}',
    );

    _expect(
      'select',
      en: '{choice,select, foo{choice=foo}bar{choice=bar}}',
      vi: '{choice,select, foo{chọn=foo}bar{chọn=bar}}',
    );

    _expect(
      'selectWithArg',
      en: '{choice,select, foo{choice=foo arg={arg}}bar{choice=bar arg={arg}}}',
      vi: '{choice,select, foo{chọn=foo tham số={arg}}bar{chọn=bar tham số={arg}}}',
    );
  });
}

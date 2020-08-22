import 'dart:io';

import 'package:arb/arb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArbFile', () {
    test('detects original', () {
      final contents = '{}';
      final arbFile = ArbFile.fromContents(contents, 'intl_messages.arb');
      expect(arbFile.isOriginal, isTrue);
    });

    test('parses @@last_modified', () {
      final d = DateTime.now().subtract(Duration(days: 1));
      final contents = '{"@@last_modified":"${d.toIso8601String()}"}';
      final arbFile = ArbFile.fromContents(contents);
      expect(arbFile.lastModified, equals(d));
    });

    group('locale', () {
      test('parses @@locale', () {
        final locale = 'en-US';
        final contents = '{"@@locale":"$locale"}';
        final arbFile = ArbFile.fromContents(contents);
        expect(arbFile.locale, equals(locale));
      });

      test('parses _locale', () {
        final locale = 'en-US';
        final contents = '{"_locale":"$locale"}';
        final arbFile = ArbFile.fromContents(contents);
        expect(arbFile.locale, equals(locale));
      });

      test('parses path', () {
        final locale = 'en-US';
        final arbFile = ArbFile.fromContents('{}', 'intl_$locale.arb');
        expect(arbFile.locale, equals(locale));
      });
    });

    group('translations', () {
      test('parses literal', () {
        final contents = '{"foo": "Bar"}';
        final arbFile = ArbFile.fromContents(contents);
        final translation = arbFile.translations.first;

        expect(translation.name, equals('foo'));
        expect(translation.toString(), equals('Literal(Bar)'));
      });

      test('parses placeholder', () {
        final contents = '{'
            '  "hello": "Hello {name}",'
            '  "@hello": {'
            '    "type": "text",'
            '    "placeholders": {'
            '      "name": {}'
            '    }'
            '  }'
            '}';
        final arbFile = ArbFile.fromContents(contents, 'intl_messages.arb');
        final translation = arbFile.translations.first;

        expect(translation.name, equals('hello'));
        expect(
            translation.toString(),
            equals('CompositeMessage([Literal(Hello ), '
                'VariableSubstitution(0)])'));
      });

      test('parses plural', () {
        final contents = '{'
            '  "@apples": {'
            '    "type": "text",'
            '    "placeholders": {'
            '      "n": {}'
            '    }'
            '  },'
            '  "apples": "{n,plural, =1{an apple}other{{n} apples}}"'
            '}';
        final arbFile = ArbFile.fromContents(contents, 'intl_messages.arb');
        final translation = arbFile.translations.first;

        expect(translation.name, equals('apples'));
        expect(
            translation.toString(),
            equals('{n,plural, '
                '=1{Literal(an apple)}'
                'other{CompositeMessage([VariableSubstitution(0), Literal( apples)])}'
                '}'));
      });

      test('parses select', () {
        final contents =
            '{"fooOrBar": "{choice,select, foo{Foo is great!}bar{Bar is awesome!}}"}';
        final arbFile = ArbFile.fromContents(contents);
        final translation = arbFile.translations.first;

        expect(translation.name, equals('fooOrBar'));
        expect(
            translation.toString(),
            equals('{choice,select, '
                'foo{Literal(Foo is great!)}'
                'bar{Literal(Bar is awesome!)}'
                '}'));
      });
    });

    test('parses file', () async {
      final arbFile = await ArbFile.fromFile(File('./intl/intl_messages.arb'));
      expect(arbFile.lastModified, isNotNull);
      expect(arbFile.translations, isNotEmpty);

      final list = arbFile.translations;
      expect(list.length, equals(8));

      expect(list[0].string.toString(),
          equals('Intl.message(, message, desc, {}, [])'));

      expect(list[1].string.toString(),
          equals('Intl.message(, messageWithArg, desc, {arg: foo}, [arg])'));

      expect(list[2].string.toString(),
          equals('Intl.message(, gender, desc, {gender: female}, [gender])'));

      expect(
          list[3].string.toString(),
          equals('Intl.message(, genderWithArg, desc, '
              '{gender: female, arg: foo}, [gender, arg])'));

      expect(list[4].string.toString(),
          equals('Intl.message(, plural, desc, {n: 1}, [n])'));

      expect(
          list[5].string.toString(),
          equals('Intl.message(, pluralWithArg, desc, '
              '{n: 1, arg: foo}, [n, arg])'));

      expect(list[6].string.toString(),
          equals('Intl.message(, select, desc, {choice: foo}, [choice])'));

      expect(
          list[7].string.toString(),
          equals('Intl.message(, selectWithArg, desc, '
              '{choice: foo, arg: bar}, [choice, arg])'));
    });
  });
}

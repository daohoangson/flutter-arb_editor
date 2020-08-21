import 'dart:io';

import 'package:arb/arb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_translation/src/intl_message.dart';

void main() {
  group('ArbFile', () {
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
        final message = arbFile.messages.first;

        expect(message.id, equals('foo'));
        expect(message.message, isA<LiteralString>());
        expect('${message.message}', equals('Literal(Bar)'));
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
        final arbFile = ArbFile.fromContents(contents);
        final message = arbFile.messages.first;

        expect(message.id, equals('hello'));
        expect(message.message, isA<CompositeMessage>());
        expect(
            message.message.toString(),
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
        final arbFile = ArbFile.fromContents(contents);
        final message = arbFile.messages.first;

        expect(message.id, equals('apples'));
        expect(message.message, isA<Plural>());
        expect(
            message.message.toString(),
            equals('{n,plural, '
                '=1{Literal(an apple)}'
                'other{CompositeMessage([VariableSubstitution(0), Literal( apples)])}'
                '}'));
      });

      test('parses select', () {
        final contents =
            '{"fooOrBar": "{choice,select, foo{Foo is great!}bar{Bar is awesome!}}"}';
        final arbFile = ArbFile.fromContents(contents);
        final message = arbFile.messages.first;

        expect(message.id, equals('fooOrBar'));
        expect(message.message, isA<Select>());
        expect(
            message.message.toString(),
            equals('{choice,select, '
                'foo{Literal(Foo is great!)}'
                'bar{Literal(Bar is awesome!)}'
                '}'));
      });
    });

    test('parses file', () async {
      final arbFile = await ArbFile.fromFile(File('./intl/intl_messages.arb'));
      expect(arbFile.lastModified, isNotNull);
      expect(arbFile.messages, isNotEmpty);

      final messages = arbFile.messages;
      expect(messages.length, equals(8));

      expect(messages[0].metadata.toString(),
          equals('Intl.message(, message, desc, {}, [])'));

      expect(messages[1].metadata.toString(),
          equals('Intl.message(, messageWithArg, desc, {arg: foo}, [arg])'));

      expect(messages[2].metadata.toString(),
          equals('Intl.message(, gender, desc, {gender: female}, [gender])'));

      expect(
          messages[3].metadata.toString(),
          equals('Intl.message(, genderWithArg, desc, '
              '{gender: female, arg: foo}, [gender, arg])'));

      expect(messages[4].metadata.toString(),
          equals('Intl.message(, plural, desc, {n: 1}, [n])'));

      expect(
          messages[5].metadata.toString(),
          equals('Intl.message(, pluralWithArg, desc, '
              '{n: 1, arg: foo}, [n, arg])'));

      expect(messages[6].metadata.toString(),
          equals('Intl.message(, select, desc, {choice: foo}, [choice])'));

      expect(
          messages[7].metadata.toString(),
          equals('Intl.message(, selectWithArg, desc, '
              '{choice: foo, arg: bar}, [choice, arg])'));
    });
  });
}

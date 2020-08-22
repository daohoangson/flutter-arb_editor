import 'package:arb/arb.dart';
import 'package:intl_translation/src/intl_message.dart';
import 'package:test/test.dart';

void main() {
  group('ArbTranslation', () {
    test('updates literal', () {
      final translation = ArbTranslation.fromIcuForm('one');
      expect('$translation', equals('one'));

      translation.update('two');
      expect('$translation', equals('two'));
    });

    test('updates placeholder', () {
      final icuForm1 = 'Hello {name}';
      final translation = ArbTranslation.fromIcuForm(icuForm1);
      final string = ArbString(MainMessage()..arguments = ['name']);
      string.original = translation;
      expect('$translation', equals(icuForm1));

      final icuForm2 = 'Welcome back, {name}';
      translation.update(icuForm2);
      expect('$translation', equals(icuForm2));
    });

    test('throws with bad placeholder', () {
      final icuForm = 'Hello {name}';
      final translation = ArbTranslation.fromIcuForm(icuForm);
      final string = ArbString(MainMessage()..arguments = ['name']);
      string.original = translation;
      expect('$translation', equals(icuForm));

      expect(() => translation.update('Welcome back, {oops}'),
          throwsArgumentError);
      expect('$translation', equals(icuForm));
    });

    test('updates plural', () {
      final icuForm1 = '{n,plural, =1{an apple}other{{n} apples}}';
      final translation = ArbTranslation.fromIcuForm(icuForm1);
      final string = ArbString(MainMessage()..arguments = ['n']);
      string.original = translation;
      expect('$translation', equals(icuForm1));

      final icuForm2 = '{n,plural, =1{a piece}other{{n} pieces}}';
      translation.update(icuForm2);
      expect('$translation', equals(icuForm2));
    });

    test('throws with bad plural', () {
      final icuForm = '{n,plural, =1{an apple}other{{n} apples}}';
      final translation = ArbTranslation.fromIcuForm(icuForm);
      final string = ArbString(MainMessage()..arguments = ['n']);
      string.original = translation;
      expect('$translation', equals(icuForm));

      expect(
          () => translation.update('Apples: {howMany}'), throwsArgumentError);
      expect('$translation', equals(icuForm));
    });

    test('updates select', () {
      final icuForm1 =
          '{choice,select, foo{Foo is great!}bar{Bar is awesome!}}';
      final translation = ArbTranslation.fromIcuForm(icuForm1);
      final string = ArbString(MainMessage()..arguments = ['choice']);
      string.original = translation;
      expect('$translation', equals(icuForm1));

      final icuForm2 = '{choice,select, ok{Okie}}';
      translation.update(icuForm2);
      expect('$translation', equals(icuForm2));
    });

    test('throws with bad select', () {
      final icuForm = '{choice,select, foo{Foo is great!}bar{Bar is awesome!}}';
      final translation = ArbTranslation.fromIcuForm(icuForm);
      final string = ArbString(MainMessage()..arguments = ['choice']);
      string.original = translation;
      expect('$translation', equals(icuForm));

      expect(
          () => translation.update('Selected: {which}'), throwsArgumentError);
      expect('$translation', equals(icuForm));
    });
  });
}

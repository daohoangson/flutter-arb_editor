import 'package:intl/intl.dart';

class L10n {
  L10n(this.localeName);

  final String localeName;

  String get message => Intl.message(
        'message',
        desc: 'desc',
        locale: localeName,
        meaning: 'meaning',
        name: 'message',
      );

  String messageWithArg(String arg) => Intl.message(
        'arg=$arg',
        args: [arg],
        examples: const {'arg': 'foo'},
        desc: 'desc',
        locale: localeName,
        meaning: 'meaning',
        name: 'messageWithArg',
      );

  String gender(String gender) => Intl.gender(
        gender,
        female: 'gender=female',
        male: 'gender=male',
        other: 'gender=other',
        args: [gender],
        examples: const {'gender': 'female'},
        desc: 'desc',
        locale: localeName,
        meaning: 'meaning',
        name: 'gender',
      );

  String genderWithArg(String gender, String arg) => Intl.gender(
        gender,
        female: 'gender=female arg=$arg',
        male: 'gender=male arg=$arg',
        other: 'gender=other arg=$arg',
        args: [gender, arg],
        examples: const {'gender': 'female', 'arg': 'foo'},
        desc: 'desc',
        locale: localeName,
        meaning: 'meaning',
        name: 'genderWithArg',
      );

  String plural(int n) => Intl.plural(
        n,
        zero: 'n=zero',
        one: 'n=one',
        two: 'n=two',
        few: 'n=few',
        many: 'n=many',
        other: 'n=other',
        args: [n],
        examples: const {'n': 1},
        desc: 'desc',
        locale: localeName,
        meaning: 'meaning',
        name: 'plural',
      );

  String pluralWithArg(int n, String arg) => Intl.plural(
        n,
        zero: 'n=zero arg=$arg',
        one: 'n=one arg=$arg',
        two: 'n=two arg=$arg',
        few: 'n=few arg=$arg',
        many: 'n=many arg=$arg',
        other: 'n=other arg=$arg',
        args: [n, arg],
        examples: const {'n': 1, 'arg': 'foo'},
        desc: 'desc',
        locale: localeName,
        meaning: 'meaning',
        name: 'pluralWithArg',
      );

  String select(String choice) => Intl.select(
        choice,
        {
          'foo': 'choice=foo',
          'bar': 'choice=bar',
        },
        args: [choice],
        examples: const {'choice': 'foo'},
        desc: 'desc',
        locale: localeName,
        meaning: 'meaning',
        name: 'select',
      );

  String selectWithArg(String choice, String arg) => Intl.select(
        choice,
        {
          'foo': 'choice=foo arg=$arg',
          'bar': 'choice=bar arg=$arg',
        },
        args: [choice, arg],
        examples: const {'choice': 'foo', 'arg': 'bar'},
        desc: 'desc',
        locale: localeName,
        meaning: 'meaning',
        name: 'selectWithArg',
      );
}

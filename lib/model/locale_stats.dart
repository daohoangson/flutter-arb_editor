import 'package:arb/arb.dart';
import 'package:arb_editor/model/project_stats.dart';

class LocaleStats {
  final String locale;
  final ProjectStats project;
  final List<ArbString> stringsNotTranslated;
  final List<ArbString> stringsTranslated;

  LocaleStats._(
    this.locale,
    this.project,
    this.stringsNotTranslated,
    this.stringsTranslated,
  );

  bool translated(ArbString string) => project.translated(string, locale);

  factory LocaleStats.of(ProjectStats project, String locale) {
    final stringsNotTranslated = <ArbString>[];
    final stringsTranslated = <ArbString>[];

    for (final string in project.project.strings) {
      if (project.translated(string, locale)) {
        stringsTranslated.add(string);
      } else {
        stringsNotTranslated.add(string);
      }
    }

    return LocaleStats._(
      locale,
      project,
      stringsNotTranslated,
      stringsTranslated,
    );
  }
}

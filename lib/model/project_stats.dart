import 'package:arb/arb.dart';

class ProjectStats {
  final String defaultLocale;
  final Iterable<String> locales;
  final ArbProject project;

  final Map<String, double> _progressByLocale;
  final Map<String, Map<String, bool>> _translatedByNameByLocale;
  final Map<String, int> _translationCountByLocale;

  ProjectStats._(
    this.defaultLocale,
    this.locales,
    this.project,
    this._progressByLocale,
    this._translatedByNameByLocale,
    this._translationCountByLocale,
  );

  double progress(String locale) => _progressByLocale[locale] ?? 0.0;

  int translationCount(String locale) => _translationCountByLocale[locale] ?? 0;

  bool translated(ArbString string, String locale) {
    if (locale == defaultLocale) return true;

    final translatedByLocale = _translatedByNameByLocale[string.name];
    if (translatedByLocale == null) return false;
    return translatedByLocale[locale] ?? false;
  }

  factory ProjectStats.of(ArbProject project) {
    final stringCountByLocale = <String, int>{};
    final translatedByNameByLocale = <String, Map<String, bool>>{};
    final translationCountByLocale = <String, int>{};

    for (final string in project.strings) {
      final translateds = translatedByNameByLocale.putIfAbsent(
          string.name, () => <String, bool>{});
      final original = string.original?.toString();
      if (original == null) continue;

      for (final locale in string.locales) {
        if (stringCountByLocale.containsKey(locale)) {
          stringCountByLocale[locale] = stringCountByLocale[locale] + 1;
        } else {
          stringCountByLocale[locale] = 1;
        }

        if (translateds[locale] = string[locale].toString() != original) {
          if (translationCountByLocale.containsKey(locale)) {
            translationCountByLocale[locale] =
                translationCountByLocale[locale] + 1;
          } else {
            translationCountByLocale[locale] = 1;
          }
        }
      }
    }

    final progressByLocale = Map.fromEntries(stringCountByLocale.keys.map(
        (locale) => MapEntry(
            locale,
            (translationCountByLocale[locale] ?? 0.0) /
                project.strings.length)));

    String defaultLocale;
    double minProgress;
    for (final progress in progressByLocale.entries) {
      if (minProgress == null || minProgress > progress.value) {
        defaultLocale = progress.key;
        minProgress = progress.value;
      }
    }

    final otherLocales = stringCountByLocale.keys
        .where((locale) => locale != defaultLocale)
        .toList();
    otherLocales.sort();

    return ProjectStats._(
      defaultLocale,
      List.unmodifiable([
        if (defaultLocale != null) defaultLocale,
        ...otherLocales,
      ]),
      project,
      progressByLocale,
      translatedByNameByLocale,
      translationCountByLocale,
    );
  }
}

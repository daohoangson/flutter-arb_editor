import 'dart:io';

import 'arb_file.dart';

class ArbProject {
  final Map<String, dynamic> errors;
  final List<ArbFile> files;
  final String localeDefault;

  final List<ArbString> _list;
  final Map<String, ArbString> _map;

  ArbProject(
    this._list,
    this._map, {
    this.errors,
    this.files,
    this.localeDefault,
  });

  int get length => _list.length;

  ArbString getString({int atIndex, String byName}) {
    assert((atIndex == null) != (byName == null),
        'Either `atIndex` or `byName` must be specified but not both of them.');
    return atIndex != null ? _list[atIndex] : _map[byName];
  }

  factory ArbProject.fromFile(List<ArbFile> files,
      {Map<String, dynamic> errors}) {
    final map = _collectStringsFromFiles(files);

    final list = map.values.toList();
    list.sort((a, b) => a.name.compareTo(b.name));

    return ArbProject(
      list,
      map,
      errors: errors,
      files: files,
      localeDefault: _guessLocaleDefault(list),
    );
  }

  static Future<ArbProject> fromDirectory(Directory dir) async {
    final futures = <Future<ArbFile>>[];
    final errors = <String, dynamic>{};
    for (final fse in dir.listSync(recursive: true, followLinks: false)) {
      if (!fse.path.endsWith('.arb')) continue;

      futures.add(ArbFile.fromFile(File(fse.path)).catchError((error) {
        errors[fse.absolute.path] = error;
        return null;
      }));
    }

    final arbFiles = await Future.wait(futures);
    return ArbProject.fromFile(arbFiles, errors: errors);
  }
}

Map<String, ArbString> _collectStringsFromFiles(Iterable<ArbFile> files) {
  final map = <String, ArbString>{};
  final _files = files.where((f) => f != null).toList(growable: false);

  for (final file in _files) {
    if (!file.isOriginal) continue;

    for (final original in file.translations) {
      final string = original.string;
      if (string == null) continue;

      map[string.name] = string;
    }
  }

  for (final file in files) {
    if (file.isOriginal) continue;

    for (final translation in file.translations) {
      final string = translation.string;
      if (string == null) continue;

      final fromMap = map.putIfAbsent(string.name, () => string);

      if (fromMap != string) {
        translation.string = fromMap;
        fromMap[file.locale] = translation;
      }
    }
  }

  return map;
}

String _guessLocaleDefault(List<ArbString> strings) {
  final counts = <String, int>{};
  for (final string in strings) {
    final original = string.original?.toString();
    if (original == null) continue;

    for (final locale in string.locales) {
      final translation = string[locale].toString();
      if (translation == original) {
        if (counts.containsKey(locale)) {
          counts[locale] = counts[locale] + 1;
        } else {
          counts[locale] = 1;
        }
      }
    }
  }
  String localeDefault;
  int maxValue;
  if (counts.isNotEmpty) {
    for (final count in counts.entries) {
      if (maxValue == null || maxValue < count.value) {
        localeDefault = count.key;
        maxValue = count.value;
      }
    }
  }

  return localeDefault;
}

import 'dart:io';

import 'arb_file.dart';
import 'message.dart';

class ArbProject {
  final Map<String, dynamic> errors;
  final List<ArbFile> files;
  final List<ArbString> strings;

  final Map<String, ArbString> _map;

  ArbProject(
    this.strings,
    this._map, {
    this.errors,
    this.files,
  });

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
    );
  }

  ArbString getStringByName(String name) => _map[name];

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

  static Map<String, ArbString> _collectStringsFromFiles(
      Iterable<ArbFile> files) {
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
        fromMap[file.locale] = translation;
      }
    }

    return map;
  }
}

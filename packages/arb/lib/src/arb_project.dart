import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl_translation/src/intl_message.dart';

import 'arb_file.dart';

@immutable
class ArbProject {
  final Map<String, dynamic> errors;
  final List<ArbFile> files;
  final List<MainMessage> messages;
  final Map<String, MainMessage> metadata;

  ArbProject({this.errors, this.files, this.messages, this.metadata});

  factory ArbProject.fromFile(List<ArbFile> files,
      {Map<String, dynamic> errors}) {
    final metadata = _collectMetadataFromFiles(files);

    final messages = metadata.values.toList();
    messages.sort((a, b) => a.name.compareTo(b.name));

    return ArbProject(
      errors: errors,
      files: files,
      messages: messages,
      metadata: metadata,
    );
  }

  static Future<ArbProject> fromDirectory(Directory dir) async {
    final futures = <Future<ArbFile>>[];
    final errors = <String, dynamic>{};
    for (final fse in dir.listSync(recursive: true, followLinks: false)) {
      if (!fse.path.endsWith('.arb')) continue;
      if (fse.path.endsWith('_messages.arb')) continue;

      futures.add(ArbFile.fromFile(File(fse.path)).catchError((error) {
        errors[fse.absolute.path] = error;
        return null;
      }));
    }

    final arbFiles = await Future.wait(futures);
    return ArbProject.fromFile(arbFiles, errors: errors);
  }
}

Map<String, MainMessage> _collectMetadataFromFiles(Iterable<ArbFile> files) {
  // ignore: prefer_collection_literals
  final map = <String, MainMessage>{};

  for (final file in files) {
    if (file == null) continue;

    for (final message in file.messages) {
      final metadata = message.metadata;
      if (metadata == null) continue;

      final fromMap = map.putIfAbsent(metadata.name, () => metadata);
      message.metadata = fromMap;

      if (fromMap != metadata) {
        fromMap.addTranslation(file.locale, message.translated);
      }
    }
  }

  return map;
}

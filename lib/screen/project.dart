import 'dart:io';

import 'package:arb/arb.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:intl_translation/src/intl_message.dart';

class ProjectScreen extends StatefulWidget {
  final String path;

  ProjectScreen(this.path);

  @override
  _ProjectState createState() => _ProjectState();
}

class _ProjectState extends State<ProjectScreen> {
  Future<ArbProject> _future;

  @override
  void initState() {
    super.initState();
    _future = ArbProject.fromDirectory(Directory(widget.path));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.path),
        ),
        body: FutureBuilder(
          builder: (context, snapshot) => snapshot.hasData
              ? _build(snapshot.data)
              : snapshot.hasError
                  ? Text('${snapshot.error} ')
                  : const Center(child: CircularProgressIndicator()),
          future: _future,
        ),
      );

  Widget _build(ArbProject project) => ListView.builder(
        itemBuilder: (context, index) =>
            _buildListTile(project.messages[index]),
        itemCount: project.messages.length,
      );

  Widget _buildListTile(MainMessage message) => ListTile(
        title: Text(message.name),
        subtitle: Text(message.translations.keys.join(', ')),
      );
}

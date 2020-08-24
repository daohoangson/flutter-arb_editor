import 'dart:io';

import 'package:arb/arb.dart';
import 'package:arb_editor/model/locale_stats.dart';
import 'package:arb_editor/model/project_stats.dart';
import 'package:arb_editor/screen/locale.dart';
import 'package:arb_editor/screen/string.dart';
import 'package:flutter/material.dart';

class ProjectScreen extends StatefulWidget {
  final String path;

  ProjectScreen(this.path);

  @override
  _ProjectState createState() => _ProjectState();
}

class _ProjectState extends State<ProjectScreen> {
  Future<ProjectStats> _future;

  @override
  void initState() {
    super.initState();
    _future = ArbProject.fromDirectory(Directory(widget.path))
        .then((value) => ProjectStats.of(value));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.path),
        ),
        body: FutureBuilder<ProjectStats>(
          builder: (context, snapshot) => snapshot.hasData
              ? _build(snapshot.data)
              : snapshot.hasError
                  ? Text('${snapshot.error} ')
                  : const Center(child: CircularProgressIndicator()),
          future: _future,
        ),
      );

  Widget _build(ProjectStats stats) => ListView.builder(
        itemBuilder: (context, i) => i == 0
            ? _buildStats(context, stats)
            : _buildListTile(stats, stats.project.strings[i - 1]),
        itemCount: stats.project.strings.length + 1,
      );

  Widget _buildListTile(ProjectStats stats, ArbString string) => ListTile(
        title: Text(
          string.original?.toString() ?? string.name,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Expanded(child: Text(string.description ?? string.name)),
            ...stats.locales.map<Widget>((locale) => Padding(
                  child: Text(
                    locale.toUpperCase(),
                    style: TextStyle(
                      color: stats.translated(string, locale)
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 4.0),
                )),
          ],
        ),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => StringScreen(string))),
      );

  Widget _buildStats(BuildContext context, ProjectStats stats) => Card(
        child: Column(
          children: [
            ListView(
              children: stats.locales
                  .map((locale) => _buildStatsLocale(context, stats, locale))
                  .toList(growable: false),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            )
          ],
        ),
      );

  Widget _buildStatsLocale(
          BuildContext context, ProjectStats stats, String locale) =>
      ListTile(
        title: Text(locale.toUpperCase()),
        subtitle: Text(
          locale == stats.defaultLocale
              ? 'Default locale'
              : 'Progress: ${(stats.progress(locale) * 100).toStringAsFixed(1)}%',
        ),
        trailing: Text(
          locale == stats.defaultLocale
              ? stats.project.strings.length.toString()
              : '${stats.translationCount(locale)} / ${stats.project.strings.length}',
        ),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => LocaleScreen(LocaleStats.of(stats, locale)))),
      );
}

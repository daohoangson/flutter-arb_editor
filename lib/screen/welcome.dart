import 'package:arb_editor/screen/project.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Welcome'),
        ),
        body: ListView(
          children: [
            _buildFileChooser(context),
          ],
        ),
      );

  Widget _buildFileChooser(BuildContext context) => RaisedButton(
        child: Text('Open a directory'),
        onPressed: () async {
          final result = await showOpenPanel(canSelectDirectories: true);
          if (result == null || result.canceled) return;

          final path = result.paths.first;
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ProjectScreen(path)));
        },
      );
}

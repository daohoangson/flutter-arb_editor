import 'package:arb/arb.dart';
import 'package:arb_editor/model/locale_stats.dart';
import 'package:arb_editor/screen/string.dart';
import 'package:flutter/material.dart';

class LocaleScreen extends StatelessWidget {
  final LocaleStats stats;

  const LocaleScreen(this.stats, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(stats.locale),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0)
            return _buildHeader(context,
                'Not translated (${stats.stringsNotTranslated.length})');
          index--;

          if (index < stats.stringsNotTranslated.length) {
            return _buildString(context, stats.stringsNotTranslated[index]);
          }
          index -= stats.stringsNotTranslated.length;

          if (index == 0)
            return _buildHeader(context,
                'Already translated (${stats.stringsTranslated.length})');
          if (index < stats.stringsTranslated.length) {
            return _buildString(context, stats.stringsTranslated[index]);
          }
          index -= stats.stringsTranslated.length;

          return const SizedBox.shrink();
        },
        itemCount: 1 +
            stats.stringsNotTranslated.length +
            1 +
            stats.stringsTranslated.length,
      ));

  Widget _buildHeader(BuildContext context, String header) => ListTile(
        title: Text(
          header,
          style: Theme.of(context).textTheme.headline5,
        ),
      );

  Widget _buildString(BuildContext context, ArbString string) => ListTile(
        title: Text(
          string.original?.toString() ?? string.name,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Expanded(child: Text(string.description ?? string.name)),
            Padding(
              child: stats.translated(string)
                  ? Text(
                      'Translated',
                      style: TextStyle(color: Colors.green),
                    )
                  : Text(
                      'Not translated',
                      style: TextStyle(color: Colors.red),
                    ),
              padding: const EdgeInsets.only(left: 4.0),
            ),
          ],
        ),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => StringScreen(
                  string,
                  locale: stats.locale,
                ))),
      );
}

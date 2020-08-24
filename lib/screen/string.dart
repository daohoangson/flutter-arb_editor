import 'package:arb/arb.dart';
import 'package:flutter/material.dart';

class StringScreen extends StatefulWidget {
  final String locale;
  final ArbString string;

  const StringScreen(this.string, {Key key, this.locale}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StringState();
}

class _StringState extends State<StringScreen> {
  final _controllers = <String, TextEditingController>{};

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.string.name),
        ),
        body: ListView(
          children: [
            _buildOriginal() ?? const SizedBox.shrink(),
            ..._buildArguments(),
            if (widget.locale != null)
              _buildLocale(widget.locale, autofocus: true),
            ..._buildLocales(),
          ],
        ),
      );

  Iterable<Widget> _buildArguments() {
    final arguments = widget.string.arguments;
    final example = widget.string.example;
    if (arguments?.isEmpty != false) return [];

    final tiles = <Widget>[
      ...arguments.map((argument) => ListTile(
            title: Text('Argument: $argument'),
            subtitle: Text(
                example.containsKey(argument) && example[argument] != null
                    ? 'Example: ${example[argument]}'
                    : 'No example'),
          )),
    ];
    return tiles;
  }

  Widget _buildLocale(String locale, {bool autofocus = false}) => ListTile(
        title: Text('Translation: $locale'),
        subtitle: Row(
          children: [
            Expanded(
              child: TextField(
                autofocus: autofocus,
                controller: _getController(locale),
              ),
            ),
          ],
        ),
      );

  Iterable<Widget> _buildLocales() => widget.string.locales
      .where((locale) => widget.locale == null || locale != widget.locale)
      .map((locale) => _buildLocale(locale));

  Widget _buildOriginal() {
    final original = widget.string.original?.toString();
    if (original == null) return null;

    return ListTile(
      title: Text(original),
      subtitle: Text(widget.string.description ?? 'No description'),
    );
  }

  TextEditingController _getController(String locale) =>
      _controllers.putIfAbsent(locale,
          () => TextEditingController(text: widget.string[locale].toString()));
}

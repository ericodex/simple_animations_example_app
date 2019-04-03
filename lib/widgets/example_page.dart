import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExamplePage extends StatefulWidget {
  final String title;
  final String pathToFile;
  final WidgetBuilder builder;
  final bool delayStartup;

  ExamplePage(
      {this.title, this.pathToFile, this.builder, this.delayStartup = false});

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  var renderBuilder = true;

  @override
  void initState() {
    if (widget.delayStartup) {
      renderBuilder = false;
      Future.delayed(Duration(milliseconds: 500)).then((_) {
        setState(() => renderBuilder = true);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _buildPage(context)),
            Container(
              height: 0.5,
              color: Colors.black26,
            ),
            _linkToSourceCode(),
          ],
        ),
      ),
    );
  }

  Widget _linkToSourceCode() {
    return Container(
      alignment: Alignment.topCenter,
      color: Color.fromARGB(255, 220, 220, 220),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 2, 5, 2),
        child: Row(
          children: <Widget>[
            Expanded(
                child:
                    Text("The source code of this demo is available online.")),
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: _openSource,
              splashColor: Colors.transparent,
            )
          ],
        ),
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          onPressed: () => setState(() {
                renderBuilder = false;
                Future.delayed(Duration(milliseconds: 200)).then((_) {
                  setState(() => renderBuilder = true);
                });
              }),
          icon: Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        )
      ],
    );
  }

  Widget _buildPage(BuildContext context) {
    if (!renderBuilder) {
      return Container();
    }
    return this.widget.builder(context);
  }

  _openSource() async {
    final url =
        "https://github.com/felixblaschke/simple_animations_example_app/blob/master/lib/examples/${widget.pathToFile}";
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}

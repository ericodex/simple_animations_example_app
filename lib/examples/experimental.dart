import 'package:flutter/material.dart';
import 'package:simple_animations_example_app/widgets/example_page.dart';

class Experiment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Hello Experimental"),
    );
  }
}

class ExperimentalDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExamplePage(
      title: "Experimental",
      pathToFile: "experimental.dart",
      delayStartup: true,
      builder: (context) => Center(child: Experiment()),
    );
  }
}

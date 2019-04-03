import 'package:flutter/widgets.dart';
import 'package:simple_animations_example_app/examples/rainbow_circle.dart';
import 'package:simple_animations_example_app/examples/typewriter_box.dart';

ExamplesConfiguration getExamplesConfiguration() {
  final configuration = ExamplesConfiguration();

  configuration.add(ExampleItem(
      name: "Typewriter Box", builder: (context) => TypewriterBoxDemo()));
  configuration.add(ExampleItem(
      name: "Rainbow Circle", builder: (context) => RainbowCircleDemo()));

  return configuration;
}

class ExamplesConfiguration {
  List<ExampleItem> allExamples = [];

  void add(ExampleItem item) {
    allExamples.add(item);
  }
}

class ExampleItem {
  final String name;
  final WidgetBuilder builder;

  ExampleItem({this.name, this.builder});
}

import 'package:flutter/widgets.dart';
import 'package:simple_animations_example_app/examples/fade-in-ui.dart';
import 'package:simple_animations_example_app/examples/fancy-background.dart';
import 'package:simple_animations_example_app/examples/rainbow_circle.dart';
import 'package:simple_animations_example_app/examples/switchlike-checkbox.dart';
import 'package:simple_animations_example_app/examples/typewriter_box.dart';
import 'package:simple_animations_example_app/examples/load_stuff_button.dart';

ExamplesConfiguration getExamplesConfiguration() {
  final configuration = ExamplesConfiguration();

  configuration.add(ExampleItem(
      name: "Typewriter Box", builder: (context) => TypewriterBoxDemo()));
  configuration.add(ExampleItem(
      name: "Rainbow Circle", builder: (context) => RainbowCircleDemo()));
  configuration.add(ExampleItem(
      name: "Switch-like Checkbox",
      builder: (context) => SwitchlikeCheckboxDemo()));
  configuration.add(
      ExampleItem(name: "Fade-in UI", builder: (context) => FadeInUiDemo()));
  configuration.add(ExampleItem(
      name: "Fancy Background", builder: (context) => FancyBackgroundDemo()));
  configuration.add(ExampleItem(
      name: "Load Stuff Button", builder: (context) => LoadStuffButtonDemo()));

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

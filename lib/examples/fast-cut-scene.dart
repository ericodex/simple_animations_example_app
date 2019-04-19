import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:simple_animations_example_app/widgets/example_page.dart';

class FastCutScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("widgetBuilder")
          .add(Duration(seconds: 2), ConstantTween(redSquare))
          .add(Duration(seconds: 2), ConstantTween(blueSquare))
    ]);

    return ControlledAnimation(
      duration: tween.duration,
      tween: tween,
      builder: (context, animation) => animation["widgetBuilder"](context),
    );
  }

  WidgetBuilder redSquare = (context) {
    return Container(
      color: Colors.red,
      child: ControlledAnimation(
          duration: Duration(seconds: 1),
          tween: Tween(begin: 50.0, end: 100.0),
          builder: (context, value) => Center(
                child: Container(
                    color: Colors.yellow, width: value, height: value),
              )),
    );
  };

  WidgetBuilder blueSquare = (context) {
    return Container(
      color: Colors.blue,
    );
  };
}

class FastCutSceneDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExamplePage(
      title: "Fast cut scene",
      pathToFile: "fast-cut-scene.dart",
      delayStartup: true,
      builder: (context) => FastCutScene(),
    );
  }
}

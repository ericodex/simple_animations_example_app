import 'package:flutter/material.dart';
import 'package:simple_animations_example_app/example_page.dart';
import 'package:simple_animations/simple_animations.dart';

class Box extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ControlledAnimation(
      duration: Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 80.0),
      builder: (context, height) {
        return ControlledAnimation(
          duration: Duration(milliseconds: 1200),
          delay: Duration(milliseconds: 800),
          tween: Tween(begin: 2.0, end: 300.0),
          builder: (context, width) {
            return Container(
              decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              width: width,
              height: height,
              child: TypewriterText(),
            );
          },
        );
      },
    );
  }
}

class TypewriterText extends StatelessWidget {
  final text = "Hello";

  @override
  Widget build(BuildContext context) {
    return ControlledAnimation(
      delay: Duration(milliseconds: 1200),
      duration: Duration(milliseconds: 800),
      tween: IntTween(begin: 0, end: text.length),
      builder: (context, textLength) {
        return Center(
          child: Text(text.substring(0, textLength),
              textScaleFactor: 2, style: TextStyle(letterSpacing: 10)),
        );
      },
    );
  }
}

class HelloTypewriterBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExamplePage(
      title: "Hello Typewriter Box",
      pathToFile: "hello_typewriter_box.dart",
      delayStartup: true,
      builder: (context) => Center(child: Box()),
    );
  }
}

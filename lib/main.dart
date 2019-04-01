import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

void main() => runApp(SimpleAnimationsExampleApp());

class SimpleAnimationsExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Simple Animations Example App",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Simple Animations Example App"),
        ),
        body: Container(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Text("Replace this with some nice words."),
              Container(
                height: 20,
              ),
              Expanded(
                child: Center(
                  child: ControlledAnimation(
                    playback: Playback.MIRROR,
                    duration: Duration(milliseconds: 2000),
                    tween: Tween(begin: 100.0, end: 250.0),
                    builder: (context, value) {
                      return Container(
                        width: value,
                        height: value,
                        color: Colors.red,
                        child: Center(
                          child: Text(
                            "Hello :-)",
                            textScaleFactor: value / 100,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
      theme: ThemeData.light().copyWith(
          appBarTheme: AppBarTheme(color: Color.fromARGB(255, 30, 30, 30))),
    );
  }
}

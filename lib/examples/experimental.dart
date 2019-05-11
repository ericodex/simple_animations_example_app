import 'package:flutter/material.dart';
import 'package:simple_animations_example_app/experimental/animation_controller_x.dart';
import 'package:simple_animations_example_app/widgets/example_page.dart';

class Experiment extends StatefulWidget {
  @override
  _ExperimentState createState() => _ExperimentState();
}

class _ExperimentState extends State<Experiment>
    with SingleTickerProviderStateMixin {
  AnimationControllerX _controller;
  Animation<double> width;

  @override
  void initState() {
    _controller = AnimationControllerX(vsync: this);
    width = Tween(begin: 0.0, end: 1.0).animate(_controller);

    _controller.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("build ${width.value}");
    return Column(
      children: <Widget>[
        _animatedContainer(),
        Row(
          children: <Widget>[
            MaterialButton(
              onPressed: _restart,
              child: Text("Restart"),
            ),
            MaterialButton(
              onPressed: _stop,
              child: Text("Stop"),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            MaterialButton(
              onPressed: () => _continue(true),
              child: Text("Forward"),
            ),
            MaterialButton(
              onPressed: () => _continue(false),
              child: Text("Forward (full d.)"),
            ),
            MaterialButton(
              onPressed: _backwards,
              child: Text("Backwards"),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            MaterialButton(
              onPressed: _combo1,
              child: Text("Combo 1"),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            MaterialButton(
              onPressed: _loopFw,
              child: Text("Loop Fw"),
            ),
            MaterialButton(
              onPressed: _loopRv,
              child: Text("Loop Rev"),
            ),
            MaterialButton(
              onPressed: _loopFw5x,
              child: Text("Loop Fw (5x)"),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            MaterialButton(
              onPressed: _mirrorFw,
              child: Text("Mirror Fw"),
            ),
            MaterialButton(
              onPressed: _mirrorRv,
              child: Text("Mirror Rev"),
            ),
            MaterialButton(
              onPressed: _mirrorFw5x,
              child: Text("Mirror Fw (5x)"),
            ),
          ],
        )
      ],
    );
  }

  Container _animatedContainer() {
    return Container(
      color: Colors.grey.shade300,
      width: 200,
      height: 200,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          color: Colors.red,
          height: 200,
          width: width.value * 200,
        ),
      ),
    );
  }

  void _stop() {
    _controller.reset();
  }

  void _restart() {
    _controller.reset();
    _controller
        .addTask(FromToAnimationTask(Duration(seconds: 2), from: 0.0, to: 1.0));
  }

  void _continue(bool compensateTime) {
    _controller.reset();
    _controller.addTask(FromToAnimationTask(Duration(seconds: 2),
        to: 1.0, recomputeDurationBasedOnProgress: compensateTime));
  }

  void _backwards() {
    _controller.reset([FromToAnimationTask(Duration(seconds: 2), to: 0.0)]);
  }

  void _combo1() {
    _controller.reset([
      SetValueAnimationTask(0.5),
      SleepAnimationTask(Duration(milliseconds: 500)),
      FromToAnimationTask(Duration(milliseconds: 1500), to: 1.0),
      FromToAnimationTask(Duration(milliseconds: 1500), to: 0.5),
      SleepAnimationTask(Duration(milliseconds: 500)),
      SetValueAnimationTask(0.0),
    ]);
  }

  void _loopFw() {
    _controller.reset([
      LoopAnimationTask(
          from: 0.0,
          to: 1.0,
          startWithCurrentPosition: false,
          iterationDuration: Duration(seconds: 1))
    ]);
  }

  void _loopRv() {
    _controller.reset([
      LoopAnimationTask(
          from: 1.0, to: 0.0, iterationDuration: Duration(seconds: 1))
    ]);
  }

  void _loopFw5x() {
    _controller.reset([
      LoopAnimationTask(
          from: 0.0,
          to: 1.0,
          iterations: 5,
          iterationDuration: Duration(seconds: 1))
    ]);
  }

  void _mirrorFw() {
    _controller.reset([
      LoopAnimationTask(
          from: 0.0,
          to: 1.0,
          mirrorIterations: true,
          startWithCurrentPosition: true,
          iterationDuration: Duration(seconds: 1))
    ]);
  }

  void _mirrorRv() {
    _controller.reset([
      LoopAnimationTask(
          from: 1.0,
          to: 0.0,
          mirrorIterations: true,
          startWithCurrentPosition: true,
          iterationDuration: Duration(seconds: 1))
    ]);
  }

  void _mirrorFw5x() {
    _controller.reset([
      LoopAnimationTask(
          from: 0.0,
          to: 1.0,
          mirrorIterations: true,
          iterations: 5,
          startWithCurrentPosition: true,
          iterationDuration: Duration(seconds: 1))
    ]);
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

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:simple_animations_example_app/widgets/example_page.dart';

class Experiment extends StatefulWidget {
  @override
  _ExperimentState createState() => _ExperimentState();
}

class _ExperimentState extends State<Experiment>
    with SingleTickerProviderStateMixin {
  AnimationControllerX _controller;
  Animation<double> width;

  bool anyCondition = false;

  @override
  void initState() {
    _controller =
        AnimationControllerX(vsync: this, onStatusChange: _onStatusChange);
    width = Tween(begin: 0.0, end: 1.0).animate(_controller);

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((animationStatus) {
      print("status change: $animationStatus");
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
    //print("build ${width.value}");
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
            MaterialButton(
              onPressed: () {
                _controller.reset([
                  SetValueTask(value: 0.3),
                  LoopTask(
                      duration: Duration(seconds: 1),
                      from: 1.0,
                      to: 0.0,
                      onIterationCompleted: () => "L1 ITERATION COMPLETE")
                ]);
                Future.delayed(Duration(milliseconds: 150)).then((_) {
                  _controller.reset([
                    LoopTask(
                        duration: Duration(seconds: 1),
                        from: 1.0,
                        to: 0.0,
                        onIterationCompleted: () => "L1 ITERATION COMPLETE")
                  ]);
                });
                Future.delayed(Duration(milliseconds: 1400)).then((_) {
                  print("STOP");
                  _controller.stop();
                });
              },
              child: Text("Test 1"),
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
        ),
        Row(
          children: <Widget>[
            MaterialButton(
              onPressed: _conditional,
              child: Text("Condiational"),
            ),
            MaterialButton(
              onPressed: () => _controller.forceCompleteCurrentTask(),
              child: Text("Force complete"),
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
    _controller.stop();
  }

  void _restart() {
    _controller.reset();
    _controller.addTask(
        FromToTask(duration: Duration(seconds: 2), from: 0.0, to: 1.0));
  }

  void _continue(bool compensateTime) {
    _controller.reset();
    _controller.addTask(FromToTask(
        duration: Duration(seconds: 2),
        to: 1.0,
        durationBasedOnZeroToOneInterval: compensateTime,
        onStart: () => print("start forward"),
        onComplete: () => print("fin forward")));
  }

  void _backwards() {
    _controller.reset([
      FromToTask(
          duration: Duration(seconds: 2),
          to: 0.0,
          onStart: () => print("start backward"),
          onComplete: () => print("fin backward"))
    ]);
  }

  void _combo1() {
    _controller.reset([
      SetValueTask(value: 0.5),
      SleepTask(duration: Duration(milliseconds: 500)),
      FromToTask(duration: Duration(milliseconds: 1500), to: 1.0),
      FromToTask(duration: Duration(milliseconds: 1500), to: 0.5),
      SleepTask(duration: Duration(milliseconds: 500)),
      SetValueTask(value: 0.0),
    ]);
  }

  void _loopFw() {
    _controller.reset([
      LoopTask(
          from: 0.0,
          to: 1.0,
          startOnCurrentPosition: false,
          duration: Duration(seconds: 1))
    ]);
  }

  void _loopRv() {
    print("LOOP RV PRESSED");
    _controller.reset([
      LoopTask(
          from: 1.0,
          to: 0.0,
          duration: Duration(seconds: 1),
          onIterationCompleted: () => print("ITERATION COMPLETE"))
    ]);
  }

  void _loopFw5x() {
    _controller.reset([
      LoopTask(
          from: 0.0,
          to: 1.0,
          iterations: 5,
          duration: Duration(seconds: 1),
          onStart: () => print("loop5x started"),
          onComplete: () => print("loop5x completed"),
          onIterationCompleted: () => print("loop5x iteration complete")),
    ]);
  }

  void _mirrorFw() {
    _controller.reset([
      LoopTask(
          from: 0.0,
          to: 1.0,
          mirror: true,
          startOnCurrentPosition: true,
          duration: Duration(seconds: 1))
    ]);
  }

  void _mirrorRv() {
    _controller.reset([
      LoopTask(
          from: 1.0,
          to: 0.0,
          mirror: true,
          startOnCurrentPosition: true,
          duration: Duration(seconds: 1))
    ]);
  }

  void _mirrorFw5x() {
    _controller.reset([
      LoopTask(
          from: 0.0,
          to: 1.0,
          mirror: true,
          iterations: 5,
          startOnCurrentPosition: true,
          duration: Duration(seconds: 1))
    ]);
  }

  _conditional() {
    setState(() {
      anyCondition = false;
    });
    _controller.addTasks([
      FromToTask(from: 0.0, to: 0.5, duration: Duration(seconds: 1)),
      ConditionalTask(
          predicate: () => anyCondition == true,
          onStart: () => print("wait for condition"),
          onComplete: () => print("condition happend")),
      FromToTask(to: 1.0, duration: Duration(seconds: 1))
    ]);
    Future.delayed(Duration(seconds: 2))
        .then((_) => setState(() => anyCondition = true));
  }

  _onStatusChange(AnimationControllerXStatus status, AnimationTask task) {
    print("X status change: $status => $task");
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

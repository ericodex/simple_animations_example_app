import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:meta/meta.dart';

class AnimationControllerX extends Animation<double>
    with
        AnimationEagerListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  Ticker _ticker;

  AnimationTask _currentTask;
  List<AnimationTask> _tasks = [];

  AnimationControllerX({@required TickerProvider vsync})
      : assert(vsync != null, "TODO provide description") {
    _ticker = vsync.createTicker(_tick);
    _ticker.start();
  }

  void _tick(Duration time) {
    if (_tasks.isEmpty && _currentTask == null) {
      return;
    }

    if (_currentTask == null) {
      _currentTask = _tasks.removeAt(0);
      _currentTask.started(time, _value);
    }

    final newValue = _currentTask.computeValue(time);
    assert(newValue != null,
        "Value passed from 'computeValue' method must be non null.");
    if (newValue != _value) {
      _value = newValue;
      notifyListeners();
    }

    if (_currentTask.isCompleted()) {
      _currentTask.dispose();
      _currentTask = null;
    }
  }

  dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  AnimationStatus get status => _status;
  AnimationStatus _status = AnimationStatus.forward;

  @override
  double get value => _value;
  double _value = 0.0;

  void addTask(FromToAnimationTask task) {
    _tasks.add(task);
  }

  void reset([List<AnimationTask> tasksToExecuteAfterReset]) {
    _tasks.clear();
    if (_currentTask != null) {
      _currentTask.dispose();
      _currentTask = null;
    }

    if (tasksToExecuteAfterReset != null) {
      _tasks.addAll(tasksToExecuteAfterReset);
    }
  }
}

class LoopAnimationTask extends AnimationTask {
  double from;
  double to;
  Duration iterationDuration;
  int iterations;
  bool startWithCurrentPosition;
  bool mirrorIterations;
  LoopAnimationTask(
      {@required this.iterationDuration,
      this.from,
      this.to,
      this.iterations,
      this.startWithCurrentPosition = true,
      this.mirrorIterations = false});

  FromToAnimationTask _currentIterationTask;
  var _iterationsPassed = 0;

  @override
  computeValue(Duration time) {
    if (_currentIterationTask == null) {
      _createAnimationTaskForCurrentIteration(time);
    }

    final value = _currentIterationTask.computeValue(time);

    if (_currentIterationTask.isCompleted()) {
      finishIteration();
    }

    return value;
  }

  void _createAnimationTaskForCurrentIteration(Duration time) {
    var fromValue = from;
    var toValue = to;

    if (startWithCurrentPosition && _iterationsPassed == 0) {
      fromValue = startedValue;
    }

    if (mirrorIterations && _iterationsPassed % 2 == 1) {
      final swapValue = toValue;
      toValue = fromValue;
      fromValue = swapValue;
    }

    _currentIterationTask =
        FromToAnimationTask(iterationDuration, from: fromValue, to: toValue);
    _currentIterationTask.started(time, startedValue);
  }

  void finishIteration() {
    _currentIterationTask.dispose();
    _currentIterationTask = null;
    _iterationsPassed++;

    if (iterations != null && _iterationsPassed == iterations) {
      taskCompleted();
    }
  }
}

class SetValueAnimationTask extends AnimationTask {
  final double value;
  SetValueAnimationTask(this.value);

  @override
  computeValue(Duration time) {
    taskCompleted();
    return value;
  }
}

class SleepAnimationTask extends AnimationTask {
  Duration sleepDuration;
  SleepAnimationTask(this.sleepDuration);

  @override
  computeValue(Duration time) {
    final timePassed = time - startedTime;
    if (timePassed.inMilliseconds >= sleepDuration.inMilliseconds) {
      taskCompleted();
    }
    return startedValue;
  }
}

class FromToAnimationTask extends AnimationTask {
  Duration duration;
  bool recomputeDurationBasedOnProgress;
  double from;
  double to;
  FromToAnimationTask(this.duration,
      {@required this.to,
      this.recomputeDurationBasedOnProgress = true,
      this.from})
      : assert(to != null,
            "Missing paramter 'to'. You need to specify a value to animate to.");

  @override
  computeValue(Duration time) {
    final fromValue = (from == null ? startedValue : from).clamp(0.0, 1.0);
    final toValue = to.clamp(0.0, 1.0);
    final delta = (toValue - fromValue).abs();
    final durationMillis = recomputeDurationBasedOnProgress
        ? delta * duration.inMilliseconds
        : duration.inMilliseconds;

    print("compute $fromValue => $toValue");

    double value;

    if (durationMillis == 0) {
      value = toValue;
    } else {
      final timePassed = time - startedTime;
      final progress = timePassed.inMilliseconds / durationMillis;
      value = (fromValue * (1 - progress) + progress * toValue)
          .clamp(min(fromValue, toValue), max(fromValue, toValue));
    }

    if (value == toValue) taskCompleted();

    return value;
  }
}

abstract class AnimationTask {
  Duration startedTime;
  double startedValue;
  bool _isCompleted = false;

  started(Duration time, double value) {
    startedTime = time;
    startedValue = value;
  }

  computeValue(Duration time);

  void taskCompleted() {
    _isCompleted = true;
  }

  bool isCompleted() => _isCompleted;

  void dispose() {}
}

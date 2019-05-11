import 'dart:math';

import 'package:meta/meta.dart';

import 'animation_controller_x.dart';
import 'animation_task.dart';

class SleepAnimationTask extends AnimationTask {
  Duration sleepDuration;
  SleepAnimationTask(
    this.sleepDuration, {
    AnimationTaskCallback onStart,
    AnimationTaskCallback onComplete,
  }) : super(onStart: onStart, onComplete: onComplete);

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

  FromToAnimationTask(
    this.duration, {
    @required this.to,
    this.recomputeDurationBasedOnProgress = true,
    this.from,
    AnimationTaskCallback onStart,
    AnimationTaskCallback onComplete,
  })  : assert(to != null,
            "Missing paramter 'to'. You need to specify a value to animate to."),
        super(onStart: onStart, onComplete: onComplete);

  @override
  computeValue(Duration time) {
    final fromValue = (from == null ? startedValue : from).clamp(0.0, 1.0);
    final toValue = to.clamp(0.0, 1.0);
    final delta = (toValue - fromValue).abs();
    final durationMillis = recomputeDurationBasedOnProgress
        ? delta * duration.inMilliseconds
        : duration.inMilliseconds;

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

class LoopAnimationTask extends AnimationTask {
  double from;
  double to;
  Duration iterationDuration;
  int iterations;
  bool startWithCurrentPosition;
  bool mirrorIterations;
  AnimationTaskCallback onIterationCompleted;
  LoopAnimationTask({
    @required this.iterationDuration,
    this.from,
    @required this.to,
    this.iterations,
    this.startWithCurrentPosition = true,
    this.mirrorIterations = false,
    this.onIterationCompleted,
    AnimationTaskCallback onStart,
    AnimationTaskCallback onComplete,
  }) : super(onStart: onStart, onComplete: onComplete);

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
    if (onIterationCompleted != null) onIterationCompleted();

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
  SetValueAnimationTask(
    this.value, {
    AnimationTaskCallback onStart,
    AnimationTaskCallback onComplete,
  }) : super(onStart: onStart, onComplete: onComplete);

  @override
  computeValue(Duration time) {
    taskCompleted();
    return value;
  }
}

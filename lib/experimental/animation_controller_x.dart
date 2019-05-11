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

  AnimationPlan _activePlan;
  List<AnimationPlan> _plans = [];

  AnimationControllerX({@required TickerProvider vsync})
      : assert(vsync != null, "TODO provide description") {
    _ticker = vsync.createTicker(_tick);
    _ticker.start();
  }

  void _tick(Duration time) {
    if (_plans.isEmpty && _activePlan == null) {
      return;
    }

    if (_activePlan == null) {
      print("start new plan");
      _activePlan = _plans.removeAt(0);
      _activePlan.started(time, _value);
    }

    final newValue = _activePlan.computeValue(time);
    assert(newValue != null,
        "Value passed from 'computeValue' method must be non null.");
    if (newValue != _value) {
      _value = newValue;
      notifyListeners();
    }

    if (_activePlan.isCompleted()) {
      print("completed plan");
      _activePlan.dispose();
      _activePlan = null;
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

  void addPlan(FromToAnimationPlan plan) {
    print("plan added");
    _plans.add(plan);
  }

  void reset([List<AnimationPlan> plansAfterReset]) {
    print("stop all plans");
    _plans.clear();
    if (_activePlan != null) {
      _activePlan.dispose();
      _activePlan = null;
    }

    if (plansAfterReset != null) {
      _plans.addAll(plansAfterReset);
    }
  }
}

class LoopAnimationPlan extends AnimationPlan {
  double from;
  double to;
  Duration iterationDuration;
  int iterations;
  bool startWithCurrentPosition;
  LoopAnimationPlan(
      {@required this.iterationDuration,
      this.from,
      this.to,
      this.iterations,
      this.startWithCurrentPosition = true});

  FromToAnimationPlan _currentIterationPlan;
  var _iterationsPassed = 0;

  @override
  computeValue(Duration time) {
    if (_currentIterationPlan == null) {
      var fromValue = from;
      final toValue = to;
      if (startWithCurrentPosition && _iterationsPassed == 0) {
        fromValue = startedValue;
      }
      _currentIterationPlan =
          FromToAnimationPlan(iterationDuration, from: fromValue, to: toValue);
      _currentIterationPlan.started(time, startedValue);
    }
    final value = _currentIterationPlan.computeValue(time);

    if (_currentIterationPlan.isCompleted()) {
      _currentIterationPlan.dispose();
      _currentIterationPlan = null;
      _iterationsPassed++;

      if (iterations != null && _iterationsPassed == iterations) {
        planCompleted();
      }
    }

    return value;
  }
}

class SetValueAnimationPlan extends AnimationPlan {
  final double value;
  SetValueAnimationPlan(this.value);

  @override
  computeValue(Duration time) {
    planCompleted();
    return value;
  }
}

class SleepAnimationPlan extends AnimationPlan {
  Duration sleepDuration;
  SleepAnimationPlan(this.sleepDuration);

  @override
  computeValue(Duration time) {
    final timePassed = time - startedTime;
    if (timePassed.inMilliseconds >= sleepDuration.inMilliseconds) {
      planCompleted();
    }
    return startedValue;
  }
}

class FromToAnimationPlan extends AnimationPlan {
  Duration duration;
  bool recomputeDurationBasedOnProgress;
  double from;
  double to;
  FromToAnimationPlan(this.duration,
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

    if (value == toValue) planCompleted();

    return value;
  }
}

abstract class AnimationPlan {
  Duration startedTime;
  double startedValue;
  bool _isCompleted = false;

  started(Duration time, double value) {
    startedTime = time;
    startedValue = value;
  }

  computeValue(Duration time);

  void planCompleted() {
    _isCompleted = true;
  }

  bool isCompleted() => _isCompleted;

  void dispose() {}
}

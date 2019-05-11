import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:meta/meta.dart';

import 'animation_task.dart';

class AnimationControllerX extends Animation<double>
    with
        AnimationEagerListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  Ticker _ticker;

  AnimationTask _currentTask;
  List<AnimationTask> _tasks = [];

  AnimationControllerX({@required TickerProvider vsync})
      : assert(vsync != null,
            "Please specify a TickerProvider. You can use the SingleTickerProviderStateMixin to get one.") {
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

  void addTask(AnimationTask task) {
    _tasks.add(task);
  }

  void addTasks(List<AnimationTask> tasks) {
    tasks.forEach((task) => addTask(task));
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

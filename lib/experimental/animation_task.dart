abstract class AnimationTask {
  Duration startedTime;
  double startedValue;
  bool _isCompleted = false;

  AnimationTaskCallback onStart;
  AnimationTaskCallback onComplete;

  AnimationTask({this.onStart, this.onComplete});

  started(Duration time, double value) {
    startedTime = time;
    startedValue = value;
    if (onStart != null) onStart();
  }

  computeValue(Duration time);

  taskCompleted() {
    _isCompleted = true;
    if (onComplete != null) onComplete();
  }

  bool isCompleted() => _isCompleted;

  void dispose() {}
}

typedef AnimationTaskCallback = Function();

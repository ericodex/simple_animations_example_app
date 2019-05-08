import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:simple_animations_example_app/widgets/example_page.dart';

class GameArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[Mole(), Mole(), Mole()],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[Mole(), Mole(), Mole()],
        )
      ],
    );
  }
}

class Mole extends StatefulWidget {
  @override
  _MoleState createState() => _MoleState();
}

class _MoleState extends State<Mole> {
  final List<MoleParticle> particles = [];

  bool _moleAlive = false;
  bool _respawnMole = true;

  @override
  void initState() {
    _restartMole();
    super.initState();
  }

  @override
  void dispose() {
    _respawnMole = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: _buildMole(),
    );
  }

  Rendering _buildMole() {
    return Rendering(
      onTick: (time) => _manageParticleLifecycle(time),
      builder: (context, time) {
        final stackedWidgets = <Widget>[];

        if (_moleAlive) {
          stackedWidgets.add(
              GestureDetector(onTap: () => _hitMole(time), child: _mole()));
        }

        particles.forEach((particle) {
          var progress = particle.progress.progress(time);
          final animation = particle.tween.transform(progress);
          stackedWidgets.add(Positioned(
            left: animation["x"],
            top: animation["y"],
            child: Transform.scale(
              scale: animation["scale"],
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(50)),
              ),
            ),
          ));
        });

        return Stack(
          overflow: Overflow.visible,
          children: stackedWidgets,
        );
      },
    );
  }

  Widget _mole() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.brown, borderRadius: BorderRadius.circular(50)),
    );
  }

  _hitMole(Duration time) {
    _moleAlive = false;
    _restartMole();
    Iterable.generate(50).forEach((i) => particles.add(MoleParticle(time)));
  }

  void _restartMole() {
    if (!_respawnMole) {
      return;
    }

    final startIn = Duration(milliseconds: 2000 + Random().nextInt(10000));
    final alive = Duration(milliseconds: 600 + Random().nextInt(2000));
    Future.delayed(startIn).then((value) => _moleAlive = true);
    Future.delayed(startIn + alive).then((value) {
      _moleAlive = false;
      _restartMole();
    });
  }

  _manageParticleLifecycle(Duration time) {
    particles.removeWhere((particle) {
      return particle.progress.progress(time) == 1;
    });
  }
}

class MoleParticle {
  Animatable tween;
  AnimationProgress progress;

  MoleParticle(Duration time) {
    final random = Random();
    final x = (100 + 200) * random.nextDouble() * (random.nextBool() ? 1 : -1);
    final y = (100 + 200) * random.nextDouble() * (random.nextBool() ? 1 : -1);

    tween = MultiTrackTween([
      Track("x").add(Duration(seconds: 1), Tween(begin: 0.0, end: x)),
      Track("y").add(Duration(seconds: 1), Tween(begin: 0.0, end: y)),
      Track("scale").add(Duration(seconds: 1), Tween(begin: 1.0, end: 0.0))
    ]);
    progress = AnimationProgress(
        startTime: time, duration: Duration(milliseconds: 600));
  }
}

class HitAMoleDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExamplePage(
      title: "Hit a mole",
      pathToFile: "hit_a_mole.dart",
      delayStartup: false,
      builder: (context) => GameArea(),
    );
  }
}

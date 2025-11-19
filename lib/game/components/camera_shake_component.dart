import 'dart:math';

import 'package:echo_world/game/black_echo_game.dart';
import 'package:flame/components.dart';

class CameraShakeComponent extends Component with HasGameRef<BlackEchoGame> {
  CameraShakeComponent({required this.duration, required this.intensity});

  final double duration; // seconds
  final double intensity; // pixels

  double _t = 0;
  Vector2? _originalPos;
  final _rng = Random();

  @override
  Future<void> onLoad() async {
    _originalPos = game.cameraComponent.viewfinder.position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_t >= duration) {
      if (_originalPos != null) {
        game.cameraComponent.viewfinder.position.setFrom(_originalPos!);
      }
      removeFromParent();
      return;
    }
    final dx = (_rng.nextDouble() * 2 - 1) * intensity;
    final dy = (_rng.nextDouble() * 2 - 1) * intensity;
    if (_originalPos != null) {
      game.cameraComponent.viewfinder.position
        ..setFrom(_originalPos!)
        ..add(Vector2(dx, dy));
    }
  }
}

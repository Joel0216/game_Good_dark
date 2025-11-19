import 'package:echo_world/game/entities/player/player.dart';
import 'package:echo_world/game/level/level_manager.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class GravityBehavior extends Behavior<PlayerComponent> {
  double _velocityY = 0;
  static const double gravity = 900; // px/s^2

  void impulse(double vy) {
    _velocityY = vy;
  }

  @override
  void update(double dt) {
    _velocityY += gravity * dt;
    parent.position.y += _velocityY * dt;
    // Suelo simple: top de la última fila de tiles
    final groundY = 11 * LevelManagerComponent.tileSize - parent.size.y / 2;
    if (parent.position.y > groundY) {
      parent.position.y = groundY;
      _velocityY = 0;
    }
  }
}

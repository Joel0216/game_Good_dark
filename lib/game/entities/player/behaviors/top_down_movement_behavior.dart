import 'package:echo_world/game/cubit/game/game_bloc.dart';
import 'package:echo_world/game/entities/player/player.dart';
import 'package:echo_world/game/level/level_models.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'dart:ui';

class TopDownMovementBehavior extends Behavior<PlayerComponent> {
  TopDownMovementBehavior({required this.gameBloc});
  final GameBloc gameBloc;

  double _stepAccum = 0;

  @override
  void update(double dt) {
    final game = parent.gameRef;
    final dir = game.input.movement;
    if (dir == Vector2.zero()) return;
    final baseSpeed = gameBloc.state.estaAgachado ? 56.0 : 128.0;
    final delta = dir.normalized() * baseSpeed * dt;
    // Intentar movimiento con comprobación de colisiones por tiles
    final proposed = parent.position + delta;
    final half = parent.size / 2;
    final rectFull = Rect.fromLTWH(
      proposed.x - half.x,
      proposed.y - half.y,
      parent.size.x,
      parent.size.y,
    );
    if (game.levelManager.isRectWalkable(rectFull)) {
      parent.position = proposed;
    } else {
      // Eje X
      final proposedX = parent.position + Vector2(delta.x, 0);
      final rectX = Rect.fromLTWH(
        proposedX.x - half.x,
        proposedX.y - half.y,
        parent.size.x,
        parent.size.y,
      );
      if (game.levelManager.isRectWalkable(rectX)) {
        parent.position = proposedX;
      }

      // Eje Y
      final proposedY = parent.position + Vector2(0, delta.y);
      final rectY = Rect.fromLTWH(
        proposedY.x - half.x,
        proposedY.y - half.y,
        parent.size.x,
        parent.size.y,
      );
      if (game.levelManager.isRectWalkable(rectY)) {
        parent.position = proposedY;
      }
    }

    // Emitir sonido de pasos según distancia recorrida
    _stepAccum += delta.length;
    final threshold = gameBloc.state.estaAgachado ? 22.0 : 34.0;
    if (_stepAccum >= threshold) {
      _stepAccum = 0;
      final nivel = gameBloc.state.estaAgachado
          ? NivelSonido.bajo
          : NivelSonido.medio;
      final ttl = gameBloc.state.estaAgachado ? 0.35 : 0.6;
      game.emitSound(parent.position.clone(), nivel, ttl: ttl);
    }
  }
}

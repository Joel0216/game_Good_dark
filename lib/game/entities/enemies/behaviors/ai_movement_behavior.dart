import 'package:echo_world/game/black_echo_game.dart';
import 'package:echo_world/game/entities/enemies/behaviors/hearing_behavior.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'dart:ui';

/// Behavior de movimiento hacia un objetivo para estados ALERTA y CAZA.
/// Lee el target del HearingBehavior y mueve el enemigo hacia él.
class AIMovementBehavior extends Behavior<PositionedEntity> {
  @override
  void update(double dt) {
    final hearing = parent.findBehavior<HearingBehavior>();

    // Solo mover si hay un target (ALERTA o CAZA)
    final target = hearing.targetActual;
    if (target == null) return;

    // Calcular dirección hacia el target
    final dir = (target - parent.position).normalized();

    // Mover usando la velocidad del estado actual con comprobación de colisiones
    final delta = dir * hearing.velocidadActual * dt;
    final proposed = parent.position + delta;
    final half = parent.size / 2;
    final rectFull = Rect.fromLTWH(
      proposed.x - half.x,
      proposed.y - half.y,
      parent.size.x,
      parent.size.y,
    );
    
    try {
      // Obtener el game para acceder a levelManager
      final game = parent.findParent<BlackEchoGame>();
      if (game != null) {
        final bool fullOK = game.levelManager.isRectWalkable(rectFull);
        if (fullOK) {
          parent.position = proposed;
        } else {
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
      } else {
        parent.position += delta;
      }
    } catch (_) {
      parent.position += delta;
    }

    super.update(dt);
  }

  void reset() {
    // No-op, placeholder for future stateful logic
  }
}

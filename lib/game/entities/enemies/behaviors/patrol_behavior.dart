import 'dart:math';
import 'package:echo_world/game/black_echo_game.dart';
import 'package:echo_world/game/entities/enemies/behaviors/hearing_behavior.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'dart:ui';

/// Behavior de patrulla errática para el estado ATORMENTADO.
/// Cambia de dirección aleatoriamente cada cierto intervalo.
class PatrolBehavior extends Behavior<PositionedEntity> {
  PatrolBehavior({this.intervaloCambio = 2.5});

  final double intervaloCambio; // Segundos entre cambios de dirección
  double _timer = 0;
  Vector2 _direccion = Vector2.zero();
  final Random _random = Random();

  @override
  void update(double dt) {
    // Solo patrullar si el HearingBehavior está en estado ATORMENTADO
    final hearing = parent.findBehavior<HearingBehavior>();
    if (hearing.estadoActual != AIState.atormentado) {
      return;
    }

    _timer += dt;
    if (_timer >= intervaloCambio) {
      _timer = 0;
      // Generar nueva dirección aleatoria normalizada
      _direccion = Vector2(
        _random.nextDouble() * 2 - 1,
        _random.nextDouble() * 2 - 1,
      )..normalize();
    }

    // Mover usando la velocidad del HearingBehavior con comprobación de colisiones
    if (_direccion.length > 0) {
      final delta = _direccion * hearing.velocidadActual * dt;
      final proposed = parent.position + delta;
      final half = parent.size / 2;
      final rectFull = Rect.fromLTWH(
        proposed.x - half.x,
        proposed.y - half.y,
        parent.size.x,
        parent.size.y,
      );
      // Acceder al LevelManager a través del game
      try {
        final game = parent.findParent<BlackEchoGame>();
        if (game != null) {
          if (game.levelManager.isRectWalkable(rectFull)) {
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
    }

    super.update(dt);
  }

  void reset() {
    _timer = 0;
    _direccion = Vector2.zero();
  }
}

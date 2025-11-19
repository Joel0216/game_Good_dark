import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:echo_world/game/cubit/game/game_bloc.dart';
import 'package:echo_world/game/entities/player/player.dart';
import 'dart:math' as math;
import 'dart:ui';

/// Comportamiento de movimiento en primera persona.
/// 
/// **Controles:**
/// - Joystick X (horizontal): Rotación izquierda/derecha (modifica heading)
/// - Joystick Y (vertical): Movimiento adelante/atrás en dirección del heading
/// 
/// **Características:**
/// - Velocidad máxima: 128 px/s (normal) / 56 px/s (sigilo)
/// - Rotación: 1.5 rad/s (~86°/s) con aceleración suave
/// - El heading se sincroniza con PlayerComponent para el raycaster
class FirstPersonMovementBehavior extends Behavior {
  FirstPersonMovementBehavior({required this.gameBloc});
  final GameBloc gameBloc;

  static const double maxSpeed = 64; // px/s (valor base)
  static const double stealthSpeed = 32; // px/s (base al agacharse)
  static const double turnSpeed = 1.2; // rad/s (base de rotación)

  // Sensibilidades (ajustables): multiplicadores aplicados sobre input
  static const double moveSensitivity = 1.5; // reducir avance global
  static const double turnSensitivity = 1.5; // reducir rotación global

  // Suavizado de rotación
  double _currentTurnVelocity = 0.0;
  static const double turnAcceleration = 6.0; // rad/s²

  @override
  void update(double dt) {
    if (parent is! PlayerComponent) return;
    
    final player = parent as PlayerComponent;
    final game = player.gameRef;
    final input = game.input;
    
    // Joystick: x = turn, y = forward/backward
    // Leer input y proteger magnitud
    final rawMove = input.movement;
    final move = rawMove.length > 1.0 ? rawMove.normalized() : rawMove;

    // Rotación con aceleración suave (aplicar sensibilidad)
    final targetTurnVelocity = move.x * turnSpeed * turnSensitivity;
    
    // Interpolar hacia la velocidad objetivo (suavizado)
    _currentTurnVelocity = _currentTurnVelocity + 
        (targetTurnVelocity - _currentTurnVelocity) * turnAcceleration * dt;
    
    // Aplicar rotación suavizada
    player.heading += _currentTurnVelocity * dt;
    
    // Normalizar heading a [-π, π]
    while (player.heading > math.pi) player.heading -= 2 * math.pi;
    while (player.heading < -math.pi) player.heading += 2 * math.pi;
    
    // Movimiento: adelante/atrás en dirección del heading
    final isStealth = gameBloc.state.estaAgachado;
    final baseVelocity = isStealth ? stealthSpeed : maxSpeed;
    final velocity = baseVelocity * moveSensitivity;
    final speed = -move.y * velocity; // Invertir: joystick arriba = adelante
    
    // Calcular desplazamiento en dirección del heading
    final dx = speed * dt * math.cos(player.heading);
    final dy = speed * dt * math.sin(player.heading);

    // Intentar desplazar con comprobación de colisiones contra el grid
    final proposed = player.position + Vector2(dx, dy);
    final half = player.size / 2;
    final rectFull = Rect.fromLTWH(
      proposed.x - half.x,
      proposed.y - half.y,
      player.size.x,
      player.size.y,
    );

    // Si el área completa es libre, aplicar movimiento
    if (game.levelManager.isRectWalkable(rectFull)) {
      player.position.setFrom(proposed);
    } else {
      // Separar ejes (permitir deslizar): intentar X y luego Y
      final proposedX = player.position + Vector2(dx, 0);
      final rectX = Rect.fromLTWH(
        proposedX.x - half.x,
        proposedX.y - half.y,
        player.size.x,
        player.size.y,
      );
      if (game.levelManager.isRectWalkable(rectX)) {
        player.position.setFrom(proposedX);
      }

      final proposedY = player.position + Vector2(0, dy);
      final rectY = Rect.fromLTWH(
        proposedY.x - half.x,
        proposedY.y - half.y,
        player.size.x,
        player.size.y,
      );
      if (game.levelManager.isRectWalkable(rectY)) {
        player.position.setFrom(proposedY);
      }
    }
  }
}

import 'package:echo_world/game/black_echo_game.dart';
import 'package:echo_world/game/cubit/game/game_bloc.dart';
import 'package:echo_world/game/entities/player/player.dart';
import 'package:echo_world/game/level/level_models.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'dart:ui';

class SideScrollMovementBehavior extends Behavior<PlayerComponent> {
  SideScrollMovementBehavior({required this.gameBloc});
  final GameBloc gameBloc;

  double _stepAccum = 0;

  @override
  void update(double dt) {
    final game = parent.gameRef;
    final dir = game.input.movement;
    final baseSpeed = gameBloc.state.estaAgachado ? 56.0 : 128.0;
    final dx = dir.x.clamp(-1, 1) * baseSpeed * dt;
    // Comprobación de colisiones horizontal (side-scroll)
    final proposedX = parent.position + Vector2(dx, 0);
    final half = parent.size / 2;
    final rectX = Rect.fromLTWH(
      proposedX.x - half.x,
      proposedX.y - half.y,
      parent.size.x,
      parent.size.y,
    );
    try {
      // Navegar por el árbol de componentes para encontrar levelManager
      final game = parent.findParent<BlackEchoGame>();
      if (game != null) {
        if (game.levelManager.isRectWalkable(rectX)) {
          parent.position.x = proposedX.x;
        }
      } else {
        parent.position.x += dx; // fallback
      }
    } catch (_) {
      parent.position.x += dx; // fallback
    }

    // Emitir pasos cada cierto desplazamiento horizontal
    _stepAccum += dx.abs();
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

import 'dart:math' as math;
import 'package:echo_world/game/black_echo_game.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/painting.dart';

/// Componente de efectos visuales para la absorción de un núcleo.
/// Genera partículas doradas que se mueven hacia el jugador.
/// En first-person, las partículas también se renderizan (efecto visual universal).
class AbsorptionVfxComponent extends Component with HasGameRef<BlackEchoGame> {
  AbsorptionVfxComponent({
    required this.nucleusPosition,
    required this.playerPosition,
  });

  final Vector2 nucleusPosition;
  final Vector2 playerPosition;
  bool _spawned = false;

  @override
  Future<void> onLoad() async {
    if (_spawned) return;
    _spawned = true;

    // Generar múltiples partículas en diferentes direcciones
    for (var i = 0; i < 20; i++) {
      final angle = (math.pi * 2 / 20) * i;
      final offset = Vector2(math.cos(angle), math.sin(angle)) * 15;
      final startPos = nucleusPosition + offset;

      // Crear partícula que viaja hacia el jugador con aceleración
      final particleSystem = ParticleSystemComponent(
        position: startPos.clone(),
        particle: Particle.generate(
          count: 1,
          lifespan: 0.6,
          generator: (i) {
            final toPlayer = (playerPosition - startPos)..normalize();
            return AcceleratedParticle(
              acceleration: toPlayer * 800,
              speed: toPlayer * 200,
              child: CircleParticle(
                radius: 3,
                paint: Paint()..color = const Color(0xFFFFD700),
              ),
            );
          },
        ),
      );

      await parent?.add(particleSystem);
    }

    // Auto-destruirse después de que las partículas terminen
    await Future<void>.delayed(const Duration(milliseconds: 700));
    removeFromParent();
  }
}

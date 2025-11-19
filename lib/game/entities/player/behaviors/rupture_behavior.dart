import 'package:echo_world/game/audio/audio_manager.dart';
// ignore: unused_import - Usado indirectamente para type casting de parent.game
import 'package:echo_world/game/black_echo_game.dart';
import 'package:echo_world/game/components/components.dart';
import 'package:echo_world/game/cubit/game/game_bloc.dart';
import 'package:echo_world/game/entities/enemies/behaviors/behaviors.dart';
import 'package:echo_world/game/entities/enemies/enemies.dart';
import 'package:echo_world/game/entities/player/player.dart';
import 'package:echo_world/game/level/level_models.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/painting.dart';

class RuptureBehavior extends Behavior<PlayerComponent> {
  RuptureBehavior({required this.gameBloc});
  final GameBloc gameBloc;

  static const double radius = 128; // 4 tiles

  Future<void> triggerRupture() async {
    if (gameBloc.state.energiaGrito < 40) return;

    final game = parent.gameRef;

    // SFX: reproducir sonido de ruptura (no-posicional, global)
    await AudioManager.instance.playSfx('rupture_blast');

    // VFX simple: sacudir cámara y añadir partículas
    game.shakeCamera(duration: 0.3);
    await game.world.add(
      ParticleSystemComponent(
        position: parent.position.clone(),
        particle: Particle.generate(
          count: 80,
          lifespan: 0.3,
          generator: (i) {
            final dir = (Vector2.random() - Vector2(0.5, 0.5))..normalize();
            return AcceleratedParticle(
              acceleration: -dir * 50,
              speed: dir * 600,
              child: CircleParticle(
                radius: 1.5,
                paint: Paint()..color = const Color(0xFFFFFFFF),
              ),
            );
          },
        ),
      ),
    );

    // Interacción: destruir paredes destructibles en radio
    final walls = game.levelManager.children.whereType<WallComponent>();
    for (final w in walls) {
      final center = w.position + w.size / 2;
      if (center.distanceTo(parent.position) <= radius) {
        w.destroy();
      }
    }

    // NUEVO: Derrotar enemigos en radio (con soporte para ResilienceBehavior)
    final enemies = game.world.children.query<PositionedEntity>();
    for (final enemy in enemies) {
      // Solo procesar enemigos (tienen behaviors)
      if (enemy is! CazadorComponent &&
          enemy is! VigiaComponent &&
          enemy is! BrutoComponent) {
        continue;
      }

      if (enemy.position.distanceTo(parent.position) <= radius) {
        // Verificar si el enemigo tiene ResilienceBehavior (solo Bruto lo tiene)
        var wasDefeated = true;

        if (enemy is BrutoComponent) {
          // Bruto tiene ResilienceBehavior: registrar hit
          final resilienceBehavior = enemy.findBehavior<ResilienceBehavior>();
          wasDefeated = resilienceBehavior.registerHit();
        }
        // Cazador y Vigía no tienen ResilienceBehavior, mueren en 1 hit (wasDefeated = true)

        if (wasDefeated) {
          // Determinar el color del enemigo para el VFX
          Color enemyColor;
          if (enemy is CazadorComponent) {
            enemyColor = const Color(0xFFFF0000); // Rojo
          } else if (enemy is VigiaComponent) {
            enemyColor = const Color(0xFFFFFF00); // Amarillo
          } else {
            enemyColor = const Color(0xFF8B4513); // Marrón (Bruto)
          }

          // Spawnear VFX de muerte (que a su vez spawneará el núcleo con delay)
          await game.world.add(
            EnemyDeathVfxComponent(
              enemyPosition: enemy.position.clone(),
              enemySize: enemy.size.clone(),
              enemyColor: enemyColor,
            ),
          );

          // Destruir enemigo inmediatamente (el VFX maneja el resto)
          enemy.removeFromParent();
        }
        // Si no fue derrotado (Bruto con 1 hit restante), sobrevive
      }
    }

    // Emisión de sonido fuerte por la ruptura
    game.emitSound(parent.position.clone(), NivelSonido.alto, ttl: 1.2);
  }
}

import 'dart:math' as math;
import 'package:echo_world/game/black_echo_game.dart';
import 'package:echo_world/game/components/components.dart';
import 'package:echo_world/game/entities/enemies/cazador.dart';
import 'package:echo_world/game/entities/enemies/vigia.dart';
import 'package:echo_world/game/entities/enemies/bruto.dart';
import 'package:echo_world/game/level/level_manager.dart';
import 'package:echo_world/game/level/level_models.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// RaycastRendererComponent: Renderiza el mundo en falso 3D (raycasting).
///
/// ═══════════════════════════════════════════════════════════════════════
/// ARQUITECTURA DE FIRST-PERSON: CÓMO FUNCIONA EL SISTEMA
/// ═══════════════════════════════════════════════════════════════════════
///
/// **PROBLEMA RESUELTO:**
/// La implementación anterior usaba un CustomPainter de Flutter como overlay,
/// lo que creaba una vista "falsa" sobre el juego 2D. Esto NO cambiaba
/// la perspectiva del juego, solo dibujaba encima.
///
/// **SOLUCIÓN IMPLEMENTADA:**
/// Este componente se integra DIRECTAMENTE en el World de Flame y reemplaza
/// completamente la vista 2D con una proyección 3D raycasting.
///
/// **FLUJO DE RENDERIZADO:**
///
/// 1. **Cambio de Enfoque** (GameBloc)
///    - Usuario presiona [ENFOQUE] → GameBloc emite `enfoqueActual: firstPerson`
///    - BlackEchoGame._ajustarCamara() detecta el cambio
///
/// 2. **Configuración de Cámara** (BlackEchoGame)
///    - `cameraComponent.stop()` → La cámara NO sigue al jugador
///    - `world.add(RaycastRendererComponent())` → Se añade este componente
///
/// 3. **Sistema de Coordenadas**
///    - Raycaster usa posición ABSOLUTA del jugador en el mundo (tiles)
///    - Renderiza directamente en coordenadas de VIEWPORT (píxeles de pantalla)
///    - NO hay transformación de cámara → la vista es fija en la pantalla
///
/// 4. **Renderizado por Frame**
///    - Este componente lee `player.position` y `player.heading`
///    - Lanza rayos desde la posición del jugador en dirección del heading
///    - Detecta colisiones con el grid de nivel y entidades
///    - Dibuja columnas verticales en el canvas (efecto 3D)
///
/// 5. **Movimiento en FP**
///    - FirstPersonMovementBehavior actualiza `player.position` (movimiento)
///    - FirstPersonMovementBehavior actualiza `player.heading` (rotación)
///    - El raycaster lee estos valores cada frame → la vista se actualiza
///
/// **DIFERENCIAS CLAVE vs. TOP-DOWN/SIDE-SCROLL:**
/// - Top-Down: Cámara sigue al jugador, vista ortogonal cenital (X, Y)
/// - Side-Scroll: Cámara sigue al jugador, vista ortogonal lateral (X, Z)
/// - First-Person: Cámara FIJA, raycaster proyecta desde jugador (3D falso)
/// 
/// **ARQUITECTURA CRÍTICA:**
/// Este componente implementa la vista FP real del juego según el GDD.
/// A diferencia de un overlay de Flutter (CustomPainter), este componente
/// se añade directamente al World de Flame y renderiza el nivel con raycasting
/// procedural desde la posición y orientación del jugador.
/// 
/// **FUNCIONAMIENTO:**
/// 1. Lanza múltiples rayos (rayCount) en el FOV del jugador (60°).
/// 2. Cada rayo marcha en el mundo (grid de nivel) detectando colisiones con:
///    - Paredes (TipoCelda.pared)
///    - Núcleos Resonantes
///    - Enemigos (Cazador, Vigía, Bruto)
/// 3. Proyecta cada colisión como una línea vertical en el canvas (columna).
/// 4. Aplica sombreado por distancia y distingue entidades por color.
/// 
/// **INTEGRACIÓN:**
/// - Se añade al World cuando enfoqueActual == Enfoque.firstPerson.
/// - Se quita del World cuando se cambia a otro enfoque.
/// - El HUD de Flutter (_HudFirstPerson) solo muestra botones, no vista 3D.
/// 
/// **RENDIMIENTO:**
/// - Renderizado procedural (sin sprites ni texturas).
/// - Optimizado para móvil con rayCount y rayStep configurables.
/// - Priority -1000 para renderizar como fondo.
class RaycastRendererComponent extends Component with HasGameRef<BlackEchoGame> {
  RaycastRendererComponent();

  // Configuración del raycasting
  static const double fov = math.pi / 3; // 60° field of view
  static const int rayCount = 160; // Número de rayos a lanzar
  static const double maxDepth = 20; // Profundidad máxima en tiles
  static const double rayStep = 0.05; // Paso de marcha para cada rayo

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final player = game.player;
    final grid = game.levelManager.currentGrid;
    
    if (grid == null) return;

    const tile = LevelManagerComponent.tileSize;
    
    // Usar el tamaño REAL del canvas del juego (toda la pantalla)
    // NO usar viewport.virtualSize que es la resolución lógica
    // game.canvasSize da el área real disponible para renderizar
    final renderSize = game.canvasSize;
    
    // Asegurar que el raycast ocupe TODO el canvas sin dejar espacios
    canvas.clipRect(Rect.fromLTWH(0, 0, renderSize.x, renderSize.y));
    
    final posX = player.position.x / tile;
    final posY = player.position.y / tile;
    final heading = player.heading;

    // Cielo y suelo (fondo)
    final skyPaint = Paint()..color = const Color(0xFF0B1C33);
    final floorPaint = Paint()..color = const Color(0xFF132A2A);
    
    // NO aplicar transformación: renderizar en espacio de canvas directamente
    canvas.drawRect(
      Rect.fromLTWH(0, 0, renderSize.x, renderSize.y / 2),
      skyPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, renderSize.y / 2, renderSize.x, renderSize.y / 2),
      floorPaint,
    );

    // Obtener entidades del mundo
    final nucleos = game.world.children.query<NucleoResonanteComponent>();
    final cazadores = game.world.children.query<CazadorComponent>();
    final vigias = game.world.children.query<VigiaComponent>();
    final brutos = game.world.children.query<BrutoComponent>();

    final colWidth = renderSize.x / rayCount;

    // Lanzar rayos
    for (var i = 0; i < rayCount; i++) {
      final rel = (i / (rayCount - 1)) - 0.5; // -0.5 a 0.5
      final rayAng = heading + rel * fov;
      final dirX = math.cos(rayAng);
      final dirY = math.sin(rayAng);

      var dist = 0.01;
      var hitX = posX;
      var hitY = posY;
      var hit = false;
      var side = false; // Para sombreado
      dynamic entidadDetectada;

      // Marcha del rayo
      while (dist < maxDepth) {
        hitX = posX + dirX * dist;
        hitY = posY + dirY * dist;
        final mx = hitX.floor();
        final my = hitY.floor();

        // Fuera de bounds
        if (my < 0 || my >= grid.length || mx < 0 || mx >= grid[0].length) {
          break;
        }

        // Detectar núcleo
        for (final n in nucleos) {
          final dx = n.position.x / tile - hitX;
          final dy = n.position.y / tile - hitY;
          if (dx.abs() < 0.4 && dy.abs() < 0.4) {
            entidadDetectada = n;
            hit = true;
            break;
          }
        }
        if (hit) break;

        // Detectar cazador
        for (final c in cazadores) {
          final dx = c.position.x / tile - hitX;
          final dy = c.position.y / tile - hitY;
          if (dx.abs() < 0.4 && dy.abs() < 0.4) {
            entidadDetectada = c;
            hit = true;
            break;
          }
        }
        if (hit) break;

        // Detectar vigía
        for (final v in vigias) {
          final dx = v.position.x / tile - hitX;
          final dy = v.position.y / tile - hitY;
          if (dx.abs() < 0.4 && dy.abs() < 0.4) {
            entidadDetectada = v;
            hit = true;
            break;
          }
        }
        if (hit) break;

        // Detectar bruto
        for (final b in brutos) {
          final dx = b.position.x / tile - hitX;
          final dy = b.position.y / tile - hitY;
          if (dx.abs() < 0.4 && dy.abs() < 0.4) {
            entidadDetectada = b;
            hit = true;
            break;
          }
        }
        if (hit) break;

        // Detectar pared
        if (grid[my][mx].tipo == TipoCelda.pared) {
          hit = true;
          side = (hitX - mx).abs() < (hitY - my).abs();
          break;
        }

        dist += rayStep;
      }

      if (!hit) continue;

      // Corrección de fisheye
      final perp = dist * math.cos(rayAng - heading);
      final wallH = (renderSize.y) / (perp + 0.0001); // Usar altura completa del canvas
      final yTop = ((renderSize.y / 2) - wallH / 2).clamp(0, renderSize.y);
      final yBottom = (yTop + wallH).clamp(0, renderSize.y);

      // Sombreado por distancia
      var shade = (1.0 - (perp / maxDepth)).clamp(0.1, 1.0);
      if (side) shade *= 0.75;

      // Color según tipo de entidad
      Color color;
      if (entidadDetectada is NucleoResonanteComponent) {
        color = Color.lerp(
          const Color(0xFFFFD700),
          const Color(0xFF002233),
          1 - shade,
        )!;
      } else if (entidadDetectada is CazadorComponent) {
        color = Color.lerp(
          const Color(0xFFFF2222),
          const Color(0xFF002233),
          1 - shade,
        )!;
      } else if (entidadDetectada is VigiaComponent) {
        color = Color.lerp(
          const Color(0xFF8A2BE2),
          const Color(0xFF002233),
          1 - shade,
        )!;
      } else if (entidadDetectada is BrutoComponent) {
        color = Color.lerp(
          const Color(0xFF4444FF),
          const Color(0xFF002233),
          1 - shade,
        )!;
      } else {
        // Pared
        color = Color.lerp(
          const Color(0xFF00FFFF),
          const Color(0xFF002233),
          1 - shade,
        )!;
      }

      final paint = Paint()
        ..color = color
        ..strokeWidth = colWidth + 1;

      final x = i * colWidth + colWidth / 2;
      canvas.drawLine(Offset(x, yTop.toDouble()), Offset(x, yBottom.toDouble()), paint);
    }
  }

  @override
  int get priority => -1000; // Renderizar antes que todo (fondo)
}

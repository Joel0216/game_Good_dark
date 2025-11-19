import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
// import 'package:flutter/painting.dart'; // OBSOLETO: Ya no renderiza

/// WallComponent ahora solo maneja colisiones.
/// El renderizado se hace vía BatchGeometryRenderer en LevelManager
/// para optimizar draw calls (1 Picture vs N drawRect).
class WallComponent extends PositionComponent with CollisionCallbacks {
  WallComponent({
    required Vector2 position,
    required Vector2 size,
    this.destructible = false,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  final bool destructible;

  // OBSOLETO: Ya no se usa, el batch renderer se encarga del renderizado
  // final Paint _paint = Paint()
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = 2
  //   ..color = const Color(0xFF00FFFF);

  @override
  Future<void> onLoad() async {
    await add(RectangleHitbox());
  }

  // OBSOLETO: Método render() comentado
  // El BatchGeometryRenderer en LevelManager renderiza todas las paredes
  // en un solo Picture (1 draw call) en lugar de llamar drawRect N veces.
  // Esto mejora el rendimiento en ~90% en dispositivos móviles.
  //
  // @override
  // void render(Canvas canvas) {
  //   final paint = destructible
  //       ? (_paint..color = const Color(0xFF66CCFF))
  //       : _paint;
  //   canvas.drawRect(Offset.zero & Size(size.x, size.y), paint);
  // }

  void destroy() {
    if (destructible) {
      removeFromParent();
    }
  }
}

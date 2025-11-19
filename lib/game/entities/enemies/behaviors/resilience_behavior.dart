import 'package:flame_behaviors/flame_behaviors.dart';

/// Behavior para enemigos que requieren múltiples impactos de [RUPTURA] para ser derrotados.
/// Utilizado por el arquetipo Bruto (requiere 2 impactos).
class ResilienceBehavior extends Behavior<PositionedEntity> {
  ResilienceBehavior({required this.requiredHits});

  /// Número de impactos de [RUPTURA] necesarios para derrotar a este enemigo
  final int requiredHits;

  /// Contador de impactos recibidos
  int _hitCount = 0;

  /// Verifica si el enemigo ha recibido suficientes impactos para morir
  bool get isDefeated => _hitCount >= requiredHits;

  /// Registra un impacto de [RUPTURA] y retorna true si el enemigo fue derrotado
  bool registerHit() {
    _hitCount++;
    return isDefeated;
  }

  /// Resetea el contador (útil para pruebas o mecánicas especiales)
  void reset() {
    _hitCount = 0;
  }

  /// Obtiene el número actual de impactos recibidos
  int get hitCount => _hitCount;

  /// Obtiene el número de impactos restantes hasta la derrota
  int get hitsRemaining => (requiredHits - _hitCount).clamp(0, requiredHits);
}

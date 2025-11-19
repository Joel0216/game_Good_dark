import 'package:echo_world/game/audio/audio_manager.dart';
import 'package:echo_world/game/components/echolocation_vfx_component.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class EcholocationBehavior extends Behavior<PositionedEntity> {
  EcholocationBehavior({required this.gameBloc});
  final dynamic
  gameBloc; // Placeholder, HUD invocará VFX directamente por ahora

  void triggerEcho(Vector2 origin) {
    // SFX: reproducir ping de ecolocalización
    AudioManager.instance.playSfx('eco_ping', volume: 0.7);

    parent.parent?.add(EcholocationVfxComponent(origin: origin));
  }
}

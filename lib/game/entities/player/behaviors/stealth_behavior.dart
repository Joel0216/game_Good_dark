import 'package:echo_world/game/cubit/game/game_bloc.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class StealthBehavior extends Behavior {
  StealthBehavior({required this.gameBloc});
  final GameBloc gameBloc;

  @override
  void update(double dt) {
    // TODO: Aplicar reducción de velocidad cuando estaAgachado == true
  }
}

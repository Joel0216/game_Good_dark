import 'package:equatable/equatable.dart';

abstract class CheckpointEvent extends Equatable {
  const CheckpointEvent();
  @override
  List<Object> get props => [];
}

/// Evento disparado cuando el jugador entra a un nuevo chunk
class ChunkCambiado extends CheckpointEvent {
  const ChunkCambiado(this.nuevoChunkId);
  final int nuevoChunkId;
  @override
  List<Object> get props => [nuevoChunkId];
}

/// Evento disparado cuando el jugador muere
class MuerteRegistrada extends CheckpointEvent {
  const MuerteRegistrada();
}

/// Evento para resetear el checkpoint (nueva partida)
class CheckpointReseteado extends CheckpointEvent {
  const CheckpointReseteado();
}

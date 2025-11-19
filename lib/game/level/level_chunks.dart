import 'package:echo_world/game/entities/enemies/cazador.dart';
import 'package:echo_world/game/entities/enemies/vigia.dart';
import 'package:echo_world/game/entities/enemies/bruto.dart';
import 'package:echo_world/game/level/level_models.dart';
import 'package:flame/components.dart';

/// Chunk inicial seguro - Tutorial básico
/// Dimensiones: 15x10 tiles
/// Sin enemigos, espacio abierto con paredes perimétricas
class ChunkInicioSeguro extends LevelData {
  ChunkInicioSeguro()
      : super(
          ancho: 15,
          alto: 10,
          nombre: 'Inicio Seguro',
          dificultad: Dificultad.tutorial,
          sector: Sector.contencion,
          grid: _buildGrid(),
          entidadesIniciales: [], // Sin enemigos
          puntosDeConexion: {
            Direccion.este: Vector2(14.5, 5), // Salida al este
            Direccion.oeste: Vector2(0.5, 5), // Entrada desde oeste
          },
        );

  static Grid _buildGrid() {
    final grid = <List<CeldaData>>[];
    for (var y = 0; y < 10; y++) {
      final row = <CeldaData>[];
      for (var x = 0; x < 15; x++) {
        // Paredes perimetrales
        if (y == 0 || y == 9 || x == 0 || x == 14) {
          row.add(CeldaData.pared);
        } else {
          // Espacio abierto interior
          row.add(CeldaData.suelo);
        }
      }
      grid.add(row);
    }
    return grid;
  }
}

/// Chunk Abismo - Requiere salto lateral
/// Dimensiones: 20x12 tiles
/// Abismo central que obliga a usar enfoque lateral para detectar plataformas
class ChunkAbismoSalto extends LevelData {
  ChunkAbismoSalto()
      : super(
          ancho: 20,
          alto: 12,
          nombre: 'Abismo del Salto',
          dificultad: Dificultad.baja,
          sector: Sector.contencion,
          grid: _buildGrid(),
          entidadesIniciales: [
            // 1 Vigía patrullando la zona de entrada
            EntidadSpawn(
              tipoEnemigo: VigiaComponent,
              posicion: Vector2(3, 6),
            ),
          ],
          puntosDeConexion: {
            Direccion.este: Vector2(19.5, 6),
            Direccion.oeste: Vector2(0.5, 6),
          },
        );

  static Grid _buildGrid() {
    final grid = <List<CeldaData>>[];
    for (var y = 0; y < 12; y++) {
      final row = <CeldaData>[];
      for (var x = 0; x < 20; x++) {
        // Paredes perimetrales
        if (y == 0 || y == 11 || x == 0 || x == 19) {
          row.add(CeldaData.pared);
        }
        // Abismo central (columnas 8-11)
        else if (x >= 8 && x <= 11) {
          // Plataforma estrecha en el medio (fila 6)
          if (y == 6) {
            row.add(CeldaData.suelo);
          } else {
            row.add(CeldaData.abismo);
          }
        }
        // Zonas seguras a los lados
        else {
          row.add(CeldaData.suelo);
        }
      }
      grid.add(row);
    }
    return grid;
  }
}

/// Chunk Sigilo con Cazador - Combate básico
/// Dimensiones: 18x14 tiles
/// Pasillo con obstáculos destructibles, 2 Cazadores patrullando
class ChunkSigiloCazador extends LevelData {
  ChunkSigiloCazador()
      : super(
          ancho: 18,
          alto: 14,
          nombre: 'Sigilo del Cazador',
          dificultad: Dificultad.media,
          sector: Sector.laboratorios,
          grid: _buildGrid(),
          entidadesIniciales: [
            // Cazador #1: zona norte
            EntidadSpawn(
              tipoEnemigo: CazadorComponent,
              posicion: Vector2(6, 4),
            ),
            // Cazador #2: zona sur
            EntidadSpawn(
              tipoEnemigo: CazadorComponent,
              posicion: Vector2(12, 10),
            ),
          ],
          puntosDeConexion: {
            Direccion.este: Vector2(17.5, 7),
            Direccion.oeste: Vector2(0.5, 7),
          },
        );

  static Grid _buildGrid() {
    final grid = <List<CeldaData>>[];
    for (var y = 0; y < 14; y++) {
      final row = <CeldaData>[];
      for (var x = 0; x < 18; x++) {
        // Paredes perimetrales
        if (y == 0 || y == 13 || x == 0 || x == 17) {
          row.add(CeldaData.pared);
        }
        // Obstáculos destructibles (columnas internas)
        else if ((x == 5 || x == 12) && y > 2 && y < 11) {
          row.add(const CeldaData(
            tipo: TipoCelda.pared,
            esDestructible: true,
          ));
        }
        // Corredor central
        else {
          row.add(CeldaData.suelo);
        }
      }
      grid.add(row);
    }
    return grid;
  }
}

/// Chunk Boss - Enfrentamiento con Bruto
/// Dimensiones: 25x18 tiles
/// Arena amplia con columnas no destructibles, 1 Bruto + 2 Vigías
class ChunkArenaBruto extends LevelData {
  ChunkArenaBruto()
      : super(
          ancho: 25,
          alto: 18,
          nombre: 'Arena del Bruto',
          dificultad: Dificultad.alta,
          sector: Sector.salida,
          grid: _buildGrid(),
          entidadesIniciales: [
            // Bruto en el centro
            EntidadSpawn(
              tipoEnemigo: BrutoComponent,
              posicion: Vector2(12.5, 9),
            ),
            // Vigía #1: esquina NE
            EntidadSpawn(
              tipoEnemigo: VigiaComponent,
              posicion: Vector2(20, 4),
            ),
            // Vigía #2: esquina SE
            EntidadSpawn(
              tipoEnemigo: VigiaComponent,
              posicion: Vector2(20, 14),
            ),
          ],
          puntosDeConexion: {
            Direccion.este: Vector2(24.5, 9),
            Direccion.oeste: Vector2(0.5, 9),
          },
        );

  static Grid _buildGrid() {
    final grid = <List<CeldaData>>[];
    for (var y = 0; y < 18; y++) {
      final row = <CeldaData>[];
      for (var x = 0; x < 25; x++) {
        // Paredes perimetrales
        if (y == 0 || y == 17 || x == 0 || x == 24) {
          row.add(CeldaData.pared);
        }
        // Columnas estructurales (no destructibles)
        else if ((x == 6 || x == 18) && (y == 6 || y == 12)) {
          row.add(const CeldaData(
            tipo: TipoCelda.pared,
          ));
        }
        // Arena central
        else {
          row.add(CeldaData.suelo);
        }
      }
      grid.add(row);
    }
    return grid;
  }
}

/// Chunk Laberinto Vertical - Requiere enfoque top-down
/// Dimensiones: 16x20 tiles
/// Pasillo zigzag vertical con Cazadores escondidos
class ChunkLaberintoVertical extends LevelData {
  ChunkLaberintoVertical()
      : super(
          ancho: 16,
          alto: 20,
          nombre: 'Laberinto Vertical',
          dificultad: Dificultad.media,
          sector: Sector.laboratorios,
          grid: _buildGrid(),
          entidadesIniciales: [
            // Cazador en curva 1
            EntidadSpawn(
              tipoEnemigo: CazadorComponent,
              posicion: Vector2(4, 8),
            ),
            // Cazador en curva 2
            EntidadSpawn(
              tipoEnemigo: CazadorComponent,
              posicion: Vector2(12, 14),
            ),
            // Vigía en la salida
            EntidadSpawn(
              tipoEnemigo: VigiaComponent,
              posicion: Vector2(8, 18),
            ),
          ],
          puntosDeConexion: {
            Direccion.norte: Vector2(8, 0.5),
            Direccion.sur: Vector2(8, 19.5),
          },
        );

  static Grid _buildGrid() {
    final grid = <List<CeldaData>>[];
    for (var y = 0; y < 20; y++) {
      final row = <CeldaData>[];
      for (var x = 0; x < 16; x++) {
        // Paredes perimetrales
        if (y == 0 || y == 19 || x == 0 || x == 15) {
          row.add(CeldaData.pared);
        }
        // Zigzag: alternar paredes cada 5 filas
        else if ((y < 5 && x > 10) ||
            (y >= 5 && y < 10 && x < 5) ||
            (y >= 10 && y < 15 && x > 10) ||
            (y >= 15 && x < 5)) {
          row.add(CeldaData.pared);
        }
        // Corredor zigzag
        else {
          row.add(CeldaData.suelo);
        }
      }
      grid.add(row);
    }
    return grid;
  }
}

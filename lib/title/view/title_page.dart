import 'dart:math' as math;
import 'package:echo_world/game/game.dart';
import 'package:echo_world/journal/journal.dart';
import 'package:echo_world/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
// IMPORTACIONES DE PÁGINAS
import 'package:echo_world/multiplayer/multiplayer.dart';
import 'package:echo_world/minigames/minigames.dart'; // MinigamesPage es ahora el selector
import 'package:echo_world/settings/settings.dart';


class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const TitlePage());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          l10n.titleAppBarTitle,
          style: const TextStyle(color: Color(0xFF00FFFF)),
        ),
      ),
      // TitleFocusHandler implementa la navegación por foco
      body: const TitleFocusHandler(),
    );
  }
}

// Widget que maneja el enfoque, la selección del botón y el movimiento vertical.
class TitleFocusHandler extends StatefulWidget {
  const TitleFocusHandler({super.key});

  @override
  State<TitleFocusHandler> createState() => _TitleFocusHandlerState();
}

class _TitleFocusHandlerState extends State<TitleFocusHandler> {
  // 0: Jugar, 1: Multijugador, 2: Minijuegos, 3: Journal, 4: Ajustes, 5: Salir
  int _selectedIndex = 0; 
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  late final List<VoidCallback> _onPressedActions;
  
  @override
  void initState() {
    super.initState();
    // Definición de las acciones de los botones
    _onPressedActions = [
      () async {
        await Navigator.of(context).pushReplacement<void, void>(GamePage.route());
      },
      () async {
        await Navigator.of(context).push<void>(MultiplayerPage.route());
      },
      () async {
        // Navega a la nueva página selectora de Minijuegos
        await Navigator.of(context).push<void>(MinigamesPage.route()); 
      },
      () async {
        await Navigator.of(context).push<void>(JournalScreen.route());
      },
      () async {
        await Navigator.of(context).push<void>(SettingsPage.route());
      },
      () => SystemNavigator.pop(),
    ];

    // Enfocar el primer botón al inicio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[_selectedIndex].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Controlador de eventos de teclado (D-Pad/Flechas)
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final maxIndex = _focusNodes.length - 1;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1).clamp(0, maxIndex);
      });
      _focusNodes[_selectedIndex].requestFocus();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1).clamp(0, maxIndex);
      });
      _focusNodes[_selectedIndex].requestFocus();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter || 
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.select) {
      _onPressedActions[_selectedIndex]();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // Widget auxiliar para el botón con efecto de enfoque
  Widget _buildTitleButton({
    required int index,
    required double buttonWidth,
    required double buttonHeight,
    required String label,
    required double scale,
    bool isPrimary = false,
  }) {
    final isFocused = _selectedIndex == index;
    const baseFontSize = 16.0; // Botones más pequeños
    final fontSize = (baseFontSize * scale).clamp(12, 24).toDouble();
    const primaryColor = Color(0xFF00FFFF);
    const secondaryColor = Color(0xFF1A1A1A);
    const focusColor = Color(0xFF8A2BE2); // Morado/Violeta para el enfoque

    // Usa un contenedor para el efecto de sombra (iluminación) al enfocar
    return Focus(
      focusNode: _focusNodes[index],
      onKeyEvent: _handleKeyEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: focusColor.withOpacity(0.8),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ]
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          width: buttonWidth,
          height: buttonHeight * 0.8, // Botón ligeramente más pequeño
          child: ElevatedButton(
            // El color del botón cambia al enfocar
            style: ElevatedButton.styleFrom(
              backgroundColor: isFocused ? focusColor : (isPrimary ? primaryColor : secondaryColor),
              foregroundColor: isFocused ? Colors.white : (isPrimary ? Colors.black : primaryColor),
              side: isPrimary ? null : BorderSide(
                color: isFocused ? Colors.white : primaryColor, 
                width: 2,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.zero,
            ),
            // Al presionar con el puntero, también actualiza el foco
            onPressed: () {
              setState(() {
                _selectedIndex = index;
              });
              _onPressedActions[index]();
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final shortest = size.shortestSide;
        final widthScale = (shortest / 360).clamp(0.65, 1.2);

        const baseTitle = 56.0;
        const baseSubtitle = 20.0;
        const baseButtonH = 54.0;
        const baseVPad = 16.0;

        final heightScale = (constraints.maxHeight / 600).clamp(0.7, 1.0); // Ajuste de altura
        final scale = math.min(widthScale.toDouble(), heightScale.toDouble());

        final double titleFont = (baseTitle * scale).clamp(24, 56).toDouble();
        final double subtitleFont = (baseSubtitle * scale).clamp(10, 24).toDouble();
        final double hPad = 24.0;
        final double vPad = baseVPad * scale;
        final double spacing = 6.0 * scale; 
        final double buttonWidth = math.min((240.0 * scale).clamp(180, 320).toDouble(), constraints.maxWidth - hPad * 2);

        return Padding(
          padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Text('BLACK ECHO', textAlign: TextAlign.center, style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold, color: const Color(0xFF00FFFF), letterSpacing: 4 * scale)), 
              SizedBox(height: 6 * scale),
              Text('Project Cassandra', textAlign: TextAlign.center, style: TextStyle(fontSize: subtitleFont, color: const Color(0xFF8A2BE2), letterSpacing: 2 * scale)), 
              const Spacer(flex: 3),
              
              _buildTitleButton(index: 0, buttonWidth: buttonWidth, buttonHeight: baseButtonH, label: l10n.titleButtonStart, scale: scale, isPrimary: true),
              SizedBox(height: spacing),

              _buildTitleButton(index: 1, buttonWidth: buttonWidth, buttonHeight: baseButtonH, label: 'MULTIJUGADOR', scale: scale),
              SizedBox(height: spacing),

              _buildTitleButton(index: 2, buttonWidth: buttonWidth, buttonHeight: baseButtonH, label: 'MINIJUEGOS', scale: scale),
              SizedBox(height: spacing),

              _buildTitleButton(index: 3, buttonWidth: buttonWidth, buttonHeight: baseButtonH, label: 'JOURNAL', scale: scale),
              SizedBox(height: spacing),

              _buildTitleButton(index: 4, buttonWidth: buttonWidth, buttonHeight: baseButtonH, label: 'AJUSTES', scale: scale),
              SizedBox(height: spacing),

              _buildTitleButton(index: 5, buttonWidth: buttonWidth, buttonHeight: baseButtonH, label: 'SALIR', scale: scale),
              
              const Spacer(flex: 2),
            ],
          ),
        );
      },
    );
  }
}

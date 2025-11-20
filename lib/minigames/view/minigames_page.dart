import 'package:echo_world/minigames/minigames.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MinigamesPage extends StatefulWidget {
  const MinigamesPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const MinigamesPage());
  }

  @override
  State<MinigamesPage> createState() => _MinigamesPageState();
}

class _MinigamesPageState extends State<MinigamesPage> {
  // 0: Cirugía PROYECT CASANDRA, 1: ?
  int _selectedIndex = 0; 
  final List<FocusNode> _focusNodes = List.generate(2, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
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
      if (_selectedIndex == 0) {
        // Inicia el juego Cirugía PROYECT CASANDRA
        Navigator.of(context).push<void>(MinigameGamePage.route());
      } else {
        // Acción para el botón '?' (Placeholder)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Minijuego secreto no disponible.')),
        );
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Widget _buildMinigameTile({
    required int index,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    String subtitle = '',
  }) {
    final isFocused = _selectedIndex == index;
    const primaryColor = Color(0xFF00FFFF);
    const focusColor = Color(0xFF8A2BE2); // Morado/Violeta
    
    return Focus(
      focusNode: _focusNodes[index],
      onKeyEvent: _handleKeyEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        // Tamaño del área de selección
        width: 320, 
        height: 180,
        decoration: BoxDecoration(
          color: isFocused ? focusColor.withOpacity(0.2) : const Color(0xFF1A1A1A),
          border: Border.all(
            color: isFocused ? focusColor : primaryColor.withOpacity(0.5),
            width: isFocused ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: focusColor.withOpacity(0.8),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ]
              : [],
        ),
        child: InkWell(
          onTap: () {
            setState(() => _selectedIndex = index);
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isFocused ? Colors.white : primaryColor,
                  size: 48, // Icono más pequeño para ajustarse
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isFocused ? Colors.white : primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty) 
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isFocused ? Colors.white70 : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'SELECCIÓN DE MINIJUEGOS',
          style: TextStyle(color: Color(0xFF00FFFF)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFFF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Primer Cuadrado: Cirugía PROYECT CASANDRA
              _buildMinigameTile(
                index: 0,
                title: 'CIRUGÍA PROYECT CASANDRA',
                subtitle: 'Eco-Negro Cirugía Casandra (Juego Web)',
                icon: Icons.biotech,
                onTap: () {
                  Navigator.of(context).push<void>(MinigameGamePage.route());
                },
              ),
              
              const SizedBox(height: 16),

              // Segundo Cuadrado: Icono de '?'
              _buildMinigameTile(
                index: 1,
                title: 'MINIJUEGO SECRETO',
                subtitle: '???',
                icon: Icons.question_mark_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Minijuego secreto no disponible.')),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

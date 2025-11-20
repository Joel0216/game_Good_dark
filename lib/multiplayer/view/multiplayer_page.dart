import 'package:flutter/material.dart';

class MultiplayerPage extends StatelessWidget {
  const MultiplayerPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const MultiplayerPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'MULTIJUGADOR',
          style: TextStyle(color: Color(0xFF00FFFF)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFFF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Funcionalidad Multijugador pendiente de desarrollo.',
            style: TextStyle(color: Color(0xFF00FFFF), fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

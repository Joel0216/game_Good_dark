import 'dart:math' as math;
import 'package:echo_world/game/game.dart';
import 'package:echo_world/journal/journal.dart';
import 'package:echo_world/l10n/l10n.dart';
import 'package:flutter/material.dart';

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
      body: const TitleView(),
    );
  }
}

class TitleView extends StatelessWidget {
  const TitleView({super.key});

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

        final baseTotalHeight = baseVPad * 2 + baseTitle * 1.15 + 6 + baseSubtitle * 1.2 + 40 + baseButtonH;

        final available = constraints.maxHeight;
        final heightScale = (available / baseTotalHeight).clamp(0.5, 1.0);
        final scale = math.min(widthScale.toDouble(), heightScale.toDouble());

        final double titleFont = (baseTitle * scale).clamp(24, 56).toDouble();
        final double subtitleFont = (baseSubtitle * scale).clamp(10, 24).toDouble();
        final double buttonHeight = (baseButtonH * scale).clamp(42, 60).toDouble();
        final double hPad = 24.0;
        final double vPad = baseVPad * scale;
        final double buttonWidth = math.min((260.0 * scale).clamp(200, 360).toDouble(), constraints.maxWidth - hPad * 2);

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
              SizedBox(width: buttonWidth, height: buttonHeight, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFFF), foregroundColor: Colors.black), onPressed: () async { await Navigator.of(context).pushReplacement<void, void>(GamePage.route()); }, child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.titleButtonStart, style: TextStyle(fontSize: (18 * scale).clamp(14, 28), fontWeight: FontWeight.bold))))),
              SizedBox(height: 12 * scale),
              SizedBox(width: buttonWidth, height: buttonHeight, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), foregroundColor: const Color(0xFF00FFFF), side: const BorderSide(color: Color(0xFF00FFFF), width: 2)), onPressed: () async { await Navigator.of(context).push<void>(JournalScreen.route()); }, child: FittedBox(fit: BoxFit.scaleDown, child: Text('JOURNAL', style: TextStyle(fontSize: (18 * scale).clamp(14, 28), fontWeight: FontWeight.bold))))),
              const Spacer(flex: 2),
            ],
          ),
        );
      },
    );
  }
}

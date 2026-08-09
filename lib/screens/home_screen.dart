import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/mode_card.dart';
import '../widgets/coming_soon_sheet.dart';
import 'calimocho_setup_screen.dart';
import 'rojo_negro_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BARAJA PARTY')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elige tu modo\nde juego',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reúne a tus amigos y que empiece la partida.',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 28),
              ModeCard(
                title: 'ROJO O NEGRO',
                subtitle: 'Ve descubriendo las cartas del mazo',
                icon: Icons.style_rounded,
                gradient: const [kRed, kOxblood],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RojoNegroScreen()),
                ),
              ),
              const SizedBox(height: 16),
              ModeCard(
                title: 'OCALIMOCHO',
                subtitle: 'El juego de la Oca, a lo bebedor',
                icon: Icons.casino_rounded,
                gradient: const [kRed, kOxblood],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalimochoSetupScreen()),
                ),
              ),
              const SizedBox(height: 16),
              ModeCard(
                title: 'MODO 3',
                subtitle: 'Nuevo modo de juego',
                icon: Icons.emoji_events_rounded,
                enabled: false,
                onTap: () => showComingSoonSheet(context, 'Modo 3'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

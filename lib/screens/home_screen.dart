import 'package:flutter/material.dart';
import '../main.dart';
import '../models/oca_player.dart';
import '../services/session_storage.dart';
import '../widgets/mode_card.dart';
import 'calimocho_screen.dart';
import 'calimocho_setup_screen.dart';
import 'ringo_screen.dart';
import 'rojo_negro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Runs once, only on a fresh app load (not when popping back to Home),
    // so a page refresh mid-game resumes where the player left off instead
    // of dumping them back to this menu.
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSession());
  }

  Future<void> _restoreSession() async {
    final state = await SessionStorage.load();
    if (!mounted || state == null) return;

    switch (state['screen']) {
      case 'rojoNegro':
        final restore = RojoNegroRestore.fromJson(state);
        if (restore == null) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => RojoNegroScreen(restore: restore)));
      case 'ringo':
        final restore = RingoRestore.fromJson(state);
        if (restore == null) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => RingoScreen(restore: restore)));
      case 'calimochoSetup':
        final players = _playersFromJson(state['players']);
        if (players == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CalimochoSetupScreen(restoredPlayers: players)),
        );
      case 'calimochoPlay':
        final players = _playersFromJson(state['players']);
        if (players == null || players.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CalimochoScreen(
              players: players,
              initialCurrentPlayerIndex: state['currentPlayerIndex'] as int? ?? 0,
              initialWinnerIndex: state['winnerIndex'] as int?,
            ),
          ),
        );
    }
  }

  List<OcaPlayer>? _playersFromJson(Object? raw) {
    if (raw is! List) return null;
    try {
      return raw.cast<Map<String, dynamic>>().map(OcaPlayer.fromJson).toList();
    } catch (_) {
      return null;
    }
  }

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
                title: 'RINGO',
                subtitle: 'Ring of Fire: cada carta es un reto',
                icon: Icons.local_fire_department_rounded,
                gradient: const [kRed, kOxblood],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RingoScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

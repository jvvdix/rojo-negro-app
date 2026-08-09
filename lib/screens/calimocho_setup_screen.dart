import 'package:flutter/material.dart';
import '../main.dart';
import '../models/oca_player.dart';
import '../widgets/primary_button.dart';
import 'calimocho_screen.dart';

class CalimochoSetupScreen extends StatefulWidget {
  const CalimochoSetupScreen({super.key});

  @override
  State<CalimochoSetupScreen> createState() => _CalimochoSetupScreenState();
}

class _CalimochoSetupScreenState extends State<CalimochoSetupScreen> {
  final _controller = TextEditingController();
  final List<OcaPlayer> _players = [];

  static const _maxPlayers = 8;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _controller.text.trim();
    if (name.isEmpty || _players.length >= _maxPlayers) return;
    setState(() {
      _players.add(OcaPlayer(name: name, color: ocaTokenColors[_players.length % ocaTokenColors.length]));
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _removePlayer(int index) {
    setState(() => _players.removeAt(index));
  }

  void _start() {
    if (_players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añade al menos 2 jugadores para empezar')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CalimochoScreen(players: _players)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = _players.length < _maxPlayers;

    return Scaffold(
      appBar: AppBar(title: const Text('CALIMOCHO')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              const Text(
                'Añade a los jugadores (2-8) antes de empezar la partida.',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (canAdd)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Nombre del jugador',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: kSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _addPlayer(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _addPlayer,
                      style: FilledButton.styleFrom(
                        backgroundColor: kRed,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Expanded(
                child: _players.isEmpty
                    ? Center(
                        child: Text(
                          'Aún no hay jugadores.\n¡Añade al menos dos para empezar!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _players.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final player = _players[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: kSurface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: player.color,
                                  child: Text(
                                    player.initial,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    player.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                                  onPressed: () => _removePlayer(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              PrimaryButton(label: 'EMPEZAR PARTIDA', onTap: _start),
            ],
          ),
        ),
      ),
    );
  }
}

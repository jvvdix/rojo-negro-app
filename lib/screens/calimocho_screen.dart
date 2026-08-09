import 'package:flutter/material.dart';
import '../main.dart';
import '../models/oca_board.dart';
import '../models/oca_player.dart';
import '../services/session_storage.dart';
import '../widgets/dice_widget.dart';
import '../widgets/oca_board_widget.dart';
import '../widgets/primary_button.dart';

class CalimochoScreen extends StatefulWidget {
  final List<OcaPlayer> players;
  final int initialCurrentPlayerIndex;
  final int? initialWinnerIndex;

  const CalimochoScreen({
    super.key,
    required this.players,
    this.initialCurrentPlayerIndex = 0,
    this.initialWinnerIndex,
  });

  @override
  State<CalimochoScreen> createState() => _CalimochoScreenState();
}

class _CalimochoScreenState extends State<CalimochoScreen> {
  late List<OcaPlayer> _players;
  late int _currentPlayerIndex;
  bool _busy = false;
  OcaPlayer? _winner;

  @override
  void initState() {
    super.initState();
    _players = widget.players;
    _currentPlayerIndex = widget.initialCurrentPlayerIndex;
    _winner = widget.initialWinnerIndex != null ? _players[widget.initialWinnerIndex!] : null;
    _persist();
  }

  void _persist() {
    SessionStorage.save({
      'screen': 'calimochoPlay',
      'players': _players.map((p) => p.toJson()).toList(),
      'currentPlayerIndex': _currentPlayerIndex,
      'winnerIndex': _winner == null ? null : _players.indexOf(_winner!),
    });
  }

  OcaPlayer get _current => _players[_currentPlayerIndex];

  Future<void> _showEvent(String message) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: kSurface,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 18),
            PrimaryButton(label: 'CONTINUAR', onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _onDiceRolled(int value) async {
    setState(() => _busy = true);
    final player = _current;
    final start = player.position;
    final rawTarget = start + value;

    if (rawTarget <= ocaBoardSquareCount) {
      for (var s = start + 1; s <= rawTarget; s++) {
        if (!mounted) return;
        setState(() => player.position = s);
        await Future.delayed(const Duration(milliseconds: 220));
      }
      if (!mounted) return;
      await _resolveSquare(player, rawTarget);
      return;
    }

    // Overshoot: walk up to the goal, then bounce back off it.
    final landing = reflectOcaPosition(start, value);
    for (var s = start + 1; s <= ocaBoardSquareCount; s++) {
      if (!mounted) return;
      setState(() => player.position = s);
      await Future.delayed(const Duration(milliseconds: 220));
    }
    if (!mounted) return;
    await _showEvent('¡Casi! Rebotas en la meta y retrocedes hasta la casilla $landing.');
    if (!mounted) return;
    for (var s = ocaBoardSquareCount - 1; s >= landing; s--) {
      if (!mounted) return;
      setState(() => player.position = s);
      await Future.delayed(const Duration(milliseconds: 220));
    }
    if (!mounted) return;
    await _resolveSquare(player, landing);
  }

  Future<void> _resolveSquare(OcaPlayer player, int squareNumber) async {
    final square = ocaSquareAt(squareNumber);

    if (square.type == OcaSquareType.goal) {
      setState(() {
        _winner = player;
        _busy = false;
      });
      _persist();
      return;
    }

    if (square.description.isNotEmpty) {
      await _showEvent(square.description);
      if (!mounted) return;
    }

    switch (square.type) {
      case OcaSquareType.inn:
        player.skippedTurnsLeft = 1;
        break;
      case OcaSquareType.jail:
        player.skippedTurnsLeft = 2;
        break;
      case OcaSquareType.bridge:
      case OcaSquareType.labyrinth:
      case OcaSquareType.skull:
        await _warpTo(player, square.jumpTo!);
        if (!mounted) return;
        break;
      case OcaSquareType.normal:
      case OcaSquareType.drink:
      case OcaSquareType.goose:
      case OcaSquareType.duel:
      case OcaSquareType.finalDare:
      case OcaSquareType.goal:
        break;
    }

    setState(() => _busy = false);
    _persist();
    _nextTurn();
  }

  Future<void> _warpTo(OcaPlayer player, int destination) async {
    setState(() => player.position = 0);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => player.position = destination);
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _nextTurn() {
    if (_winner != null) return;
    setState(() {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    });
    _resolveForcedSkip();
  }

  Future<void> _resolveForcedSkip() async {
    final player = _current;

    if (player.skippedTurnsLeft > 0) {
      setState(() => _busy = true);
      player.skippedTurnsLeft--;
      await _showEvent('${player.name} pierde este turno. Bebe.');
      if (!mounted) return;
      setState(() => _busy = false);
      _persist();
      _nextTurn();
    }
  }

  void _playAgain() {
    setState(() {
      for (final p in _players) {
        p.position = 0;
        p.skippedTurnsLeft = 0;
      }
      _currentPlayerIndex = 0;
      _winner = null;
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final winner = _winner;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) SessionStorage.clear();
      },
      child: Scaffold(
      appBar: AppBar(title: const Text('OCALIMOCHO')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
              child: Column(
                children: [
                  _TurnBar(player: _current),
                  const SizedBox(height: 8),
                  Expanded(
                    child: OcaBoardWidget(players: _players, currentPlayerIndex: _currentPlayerIndex),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: DiceWidget(enabled: !_busy && winner == null, onRolled: _onDiceRolled),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    winner == null ? 'Toca el dado para tirar' : '',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: winner == null ? null : _WinSheet(winner: winner, onPlayAgain: _playAgain),
      ),
    );
  }
}

class _TurnBar extends StatelessWidget {
  final OcaPlayer player;

  const _TurnBar({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: player.color,
            child: Text(
              player.initial,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'TURNO: ${player.name.toUpperCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _WinSheet extends StatelessWidget {
  final OcaPlayer winner;
  final VoidCallback onPlayAgain;

  const _WinSheet({required this.winner, required this.onPlayAgain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      decoration: const BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏁', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            '¡${winner.name.toUpperCase()} GANÓ!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: kFontDisplay,
              color: Colors.white,
              fontSize: 24,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Todos beben por ti.',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 18),
          PrimaryButton(label: 'JUGAR DE NUEVO', onTap: onPlayAgain),
        ],
      ),
    );
  }
}

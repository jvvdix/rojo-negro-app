import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../models/playing_card.dart';
import '../widgets/playing_card_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/tap_scale.dart';

class RojoNegroScreen extends StatefulWidget {
  const RojoNegroScreen({super.key});

  @override
  State<RojoNegroScreen> createState() => _RojoNegroScreenState();
}

class _RojoNegroScreenState extends State<RojoNegroScreen> {
  // Matches the AnimatedSwitcher transition below so a new tap never lands
  // mid-animation; keeps a fast double-tap from burning two cards at once.
  static const _inputCooldown = Duration(milliseconds: 350);

  late Deck _deck;
  late PlayingCard _currentCard;
  bool _inputLocked = false;

  @override
  void initState() {
    super.initState();
    _deck = Deck.shuffled();
    _currentCard = _deck.draw();
  }

  void _nextCard() {
    if (_deck.isEmpty || _inputLocked) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentCard = _deck.draw();
      _inputLocked = true;
    });
    Future.delayed(_inputCooldown, () {
      if (!mounted) return;
      setState(() => _inputLocked = false);
    });
  }

  void _reshuffle() {
    setState(() {
      _deck = Deck.shuffled();
      _currentCard = _deck.draw();
      _inputLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deckEmpty = _deck.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('ROJO O NEGRO')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              _StatusBar(remaining: _deck.remaining),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 240,
                    child: TapScale(
                      onTap: (deckEmpty || _inputLocked) ? null : _nextCard,
                      pressedScale: 0.97,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) => SlideTransition(
                          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                          child: FadeTransition(opacity: animation, child: child),
                        ),
                        child: CardFrontFace(key: ValueKey(_currentCard), card: _currentCard),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                deckEmpty ? '¡Mazo agotado!' : 'Toca la carta para pasar a la siguiente',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 16),
              if (deckEmpty) PrimaryButton(label: 'EMPEZAR DE NUEVO', onTap: _reshuffle),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final int remaining;

  const _StatusBar({required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'MAZO: $remaining',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

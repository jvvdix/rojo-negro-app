import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../models/playing_card.dart';
import '../models/ringo_rule.dart';
import '../services/session_storage.dart';
import '../widgets/card_back_widget.dart';
import '../widgets/playing_card_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/tap_scale.dart';

/// Snapshot of an in-progress Ringo session, restored after a refresh.
class RingoRestore {
  final List<PlayingCard> remainingCards;
  final int kingsDrawn;

  const RingoRestore({required this.remainingCards, required this.kingsDrawn});

  static RingoRestore? fromJson(Map<String, dynamic> json) {
    try {
      final cards = (json['cards'] as List)
          .cast<Map<String, dynamic>>()
          .map(PlayingCard.fromJson)
          .toList();
      final kings = json['kingsDrawn'] as int? ?? 0;
      return RingoRestore(remainingCards: cards, kingsDrawn: kings);
    } catch (_) {
      return null;
    }
  }
}

class RingoScreen extends StatefulWidget {
  final RingoRestore? restore;

  const RingoScreen({super.key, this.restore});

  @override
  State<RingoScreen> createState() => _RingoScreenState();
}

class _RingoScreenState extends State<RingoScreen>
    with SingleTickerProviderStateMixin {
  static const _spreadSize = 7;
  static const _dismissCooldown = Duration(milliseconds: 260);

  late Deck _deck;
  late final AnimationController _flipController;
  int _kingsDrawn = 0;
  PlayingCard? _revealedCard;
  bool _isFourthKingMoment = false;
  bool _inputLocked = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    final restore = widget.restore;
    if (restore != null) {
      _deck = Deck.fromCards(restore.remainingCards);
      _kingsDrawn = restore.kingsDrawn;
    } else {
      _deck = Deck.shuffled();
    }
    _persist();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _persist() {
    SessionStorage.save({
      'screen': 'ringo',
      'cards': _deck.toJson(),
      'kingsDrawn': _kingsDrawn,
    });
  }

  void _reveal(PlayingCard card) {
    if (_inputLocked) return;
    HapticFeedback.selectionClick();
    final isKing = card.rank == 13;
    final newKingsDrawn = isKing ? _kingsDrawn + 1 : _kingsDrawn;
    final isFourthKing = isKing && newKingsDrawn == 4;
    setState(() {
      _deck.drawCard(card);
      _kingsDrawn = newKingsDrawn;
      _revealedCard = card;
      _isFourthKingMoment = isFourthKing;
      _inputLocked = true;
    });
    _persist();
    _flipController.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      if (isFourthKing) HapticFeedback.heavyImpact();
      setState(() => _inputLocked = false);
    });
  }

  void _dismissReveal() {
    if (_inputLocked) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (_isFourthKingMoment) _kingsDrawn = 0;
      _revealedCard = null;
      _isFourthKingMoment = false;
      _inputLocked = true;
    });
    _persist();
    Future.delayed(_dismissCooldown, () {
      if (!mounted) return;
      setState(() => _inputLocked = false);
    });
  }

  void _reshuffle() {
    setState(() {
      _deck = Deck.shuffled();
      _kingsDrawn = 0;
      _revealedCard = null;
      _isFourthKingMoment = false;
      _inputLocked = false;
    });
    _persist();
  }

  Widget _buildStage(List<PlayingCard> spread, bool deckEmpty) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: _revealedCard != null
          ? _RevealPanel(
              key: const ValueKey('reveal'),
              card: _revealedCard!,
              controller: _flipController,
              isFourthKing: _isFourthKingMoment,
              onTap: _dismissReveal,
            )
          : deckEmpty
          ? const SizedBox(key: ValueKey('empty'))
          : _FanSpread(
              key: const ValueKey('fan'),
              cards: spread,
              onPick: _inputLocked ? null : _reveal,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spread = _deck.peek(_spreadSize);
    final deckEmpty = _deck.isEmpty && _revealedCard == null;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) SessionStorage.clear();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('RINGO')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    _StatusBar(
                      remaining:
                          _deck.remaining + (_revealedCard != null ? 1 : 0),
                      kingsDrawn: _kingsDrawn,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Center(
                                  child: _buildStage(spread, deckEmpty),
                                ),
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      deckEmpty
                          ? '¡Mazo agotado!'
                          : _revealedCard != null
                          ? 'Toca la carta para continuar'
                          : 'Elige una carta boca abajo para revelarla',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (deckEmpty)
                      PrimaryButton(
                        label: 'EMPEZAR DE NUEVO',
                        onTap: _reshuffle,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final int remaining;
  final int kingsDrawn;

  const _StatusBar({required this.remaining, required this.kingsDrawn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Row(
            children: [
              const Text(
                'REYES',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              for (var i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < kingsDrawn ? kGold : kSurfaceRaised,
                      border: i < kingsDrawn
                          ? null
                          : Border.all(color: Colors.white24, width: 1),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A face-down hand of the next cards to be drawn, splayed like a fan held in
/// the hand. The player is free to lift whichever one they want.
class _FanSpread extends StatelessWidget {
  final List<PlayingCard> cards;
  final ValueChanged<PlayingCard>? onPick;

  const _FanSpread({super.key, required this.cards, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final count = cards.length;
    final mid = (count - 1) / 2;
    // Paint the outer cards first and the center-most card last (on top),
    // like a real fanned hand held in front of you.
    final paintOrder = List<int>.generate(count, (i) => i)
      ..sort((a, b) => (b - mid).abs().compareTo((a - mid).abs()));

    return SizedBox(
      height: 230,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          for (final i in paintOrder) _buildCard(i, count, mid, cards[i]),
        ],
      ),
    );
  }

  Widget _buildCard(int i, int count, double mid, PlayingCard card) {
    final d = i - mid;
    final angle = d * 0.15;
    final dx = d * 44.0;
    final dy = d * d * 3.5;
    return Positioned(
      bottom: -dy,
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: Transform.rotate(
          angle: angle,
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            key: ValueKey(card),
            width: 96,
            child: TapScale(
              onTap: onPick == null ? null : () => onPick!(card),
              child: const CardBackWidget(),
            ),
          ),
        ),
      ),
    );
  }
}

/// The lifted, flipped card together with its rule text. The 4th King gets a
/// visibly bigger, gold-lit treatment — the one moment gold is allowed to
/// take over the screen.
class _RevealPanel extends StatelessWidget {
  final PlayingCard card;
  final AnimationController controller;
  final bool isFourthKing;
  final VoidCallback onTap;

  const _RevealPanel({
    super.key,
    required this.card,
    required this.controller,
    required this.isFourthKing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rule = ringoRuleFor(card, isFourthKing: isFourthKing);

    return TapScale(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 220,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final angle = controller.value * pi;
                final showFront = angle > pi / 2;
                final displayAngle = showFront ? angle - pi : angle;
                final lift = Curves.easeOutCubic.transform(controller.value);
                return Transform.scale(
                  scale: 0.88 + 0.12 * lift,
                  child: Container(
                    decoration: isFourthKing
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kGold.withValues(alpha: 0.35 * lift),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                          )
                        : null,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(displayAngle),
                      child: showFront
                          ? CardFrontFace(card: card)
                          : const CardBackWidget(),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final opacity = ((controller.value - 0.55) / 0.45).clamp(
                0.0,
                1.0,
              );
              return Opacity(opacity: opacity, child: child);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rule.headline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: isFourthKing ? kFontDisplay : null,
                    color: isFourthKing ? kGold : Colors.white,
                    fontSize: isFourthKing ? 28 : 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    rule.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

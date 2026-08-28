import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../models/playing_card.dart';
import '../models/ringo_circle.dart';
import '../models/ringo_rule.dart';
import '../services/session_storage.dart';
import '../widgets/card_back_widget.dart';
import '../widgets/playing_card_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/tap_scale.dart';

/// Snapshot of an in-progress Ringo session, restored after a refresh.
class RingoRestore {
  final List<PlayingCard?> slots;
  final int kingsDrawn;
  final bool circleBroken;

  const RingoRestore({
    required this.slots,
    required this.kingsDrawn,
    required this.circleBroken,
  });

  static RingoRestore? fromJson(Map<String, dynamic> json) {
    try {
      final slots = RingoCircle.slotsFromJson(json['slots'] as List);
      final kings = json['kingsDrawn'] as int? ?? 0;
      final broken = json['circleBroken'] as bool? ?? false;
      return RingoRestore(
        slots: slots,
        kingsDrawn: kings,
        circleBroken: broken,
      );
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
  static const _dismissCooldown = Duration(milliseconds: 260);

  late RingoCircle _circle;
  late final AnimationController _flipController;
  int _kingsDrawn = 0;
  bool _circleBroken = false;
  PlayingCard? _revealedCard;
  RingoClimax? _climax;
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
      _circle = RingoCircle.fromSlots(restore.slots);
      _kingsDrawn = restore.kingsDrawn;
      _circleBroken = restore.circleBroken;
    } else {
      _circle = RingoCircle.shuffled();
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
      'slots': _circle.toJson(),
      'kingsDrawn': _kingsDrawn,
      'circleBroken': _circleBroken,
    });
  }

  void _reveal(int index) {
    if (_inputLocked) return;
    HapticFeedback.selectionClick();
    final pick = _circle.drawAt(index);
    final card = pick.card;
    final isKing = card.rank == 13;
    final newKingsDrawn = isKing ? _kingsDrawn + 1 : _kingsDrawn;
    final isFourthKing = isKing && newKingsDrawn == 4;
    final breaksCircleNow = !_circleBroken && !isFourthKing && pick.brokeCircle;
    final climax = isFourthKing
        ? RingoClimax.king
        : breaksCircleNow
        ? RingoClimax.circleBroken
        : null;
    setState(() {
      _kingsDrawn = newKingsDrawn;
      _revealedCard = card;
      _climax = climax;
      if (breaksCircleNow) _circleBroken = true;
      _inputLocked = true;
    });
    _persist();
    _flipController.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      if (climax != null) HapticFeedback.heavyImpact();
      setState(() => _inputLocked = false);
    });
  }

  void _dismissReveal() {
    if (_inputLocked) return;
    HapticFeedback.selectionClick();
    final wasCircleBroken = _climax == RingoClimax.circleBroken;
    setState(() {
      if (_climax != null) _kingsDrawn = 0;
      // A broken circle empties the glass, then the remaining cards (not a
      // fresh deck) get gathered and reshuffled into a new, smaller, gap-free
      // circle — the game keeps going, and that circle can break again too.
      if (wasCircleBroken) {
        final remaining = _circle.slots.whereType<PlayingCard>().toList()
          ..shuffle();
        _circle = RingoCircle.fromSlots(remaining);
        _circleBroken = false;
      }
      _revealedCard = null;
      _climax = null;
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
      _circle = RingoCircle.shuffled();
      _kingsDrawn = 0;
      _circleBroken = false;
      _revealedCard = null;
      _climax = null;
      _inputLocked = false;
    });
    _persist();
  }

  Widget _buildStage(bool deckEmpty, bool isWide) {
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
              climax: _climax,
              isWide: isWide,
              onTap: _dismissReveal,
            )
          : deckEmpty
          ? const SizedBox(key: ValueKey('empty'))
          : _CardRing(
              key: const ValueKey('ring'),
              slots: _circle.slots,
              isWide: isWide,
              onPick: _inputLocked ? null : _reveal,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deckEmpty = _circle.isEmpty && _revealedCard == null;
    // Only the ring itself grows on a wide (desktop) window — the header and
    // footer stay phone-width so they read the same everywhere.
    final isWide = MediaQuery.sizeOf(context).width > 700;

    Widget capped(Widget child) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: child,
      ),
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) SessionStorage.clear();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('RINGO')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              children: [
                capped(
                  _StatusBar(
                    remaining: _circle.remaining,
                    kingsDrawn: _kingsDrawn,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(child: _buildStage(deckEmpty, isWide)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                capped(
                  Text(
                    deckEmpty
                        ? '¡Mazo agotado!'
                        : _revealedCard != null
                        ? 'Toca la carta para continuar'
                        : 'Arrastra para girar el círculo y elige una carta',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                if (deckEmpty)
                  capped(
                    PrimaryButton(label: 'EMPEZAR DE NUEVO', onTap: _reshuffle),
                  ),
              ],
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

/// The whole deck laid out once around the table, face down, like the real
/// Kings Cup setup. Drag anywhere on the ring to spin it — a flick keeps
/// spinning and settles like a real wheel — and tap any card to lift it.
/// A picked card's slot stays behind as a visible gap instead of closing up.
class _CardRing extends StatefulWidget {
  final List<PlayingCard?> slots;
  final bool isWide;
  final ValueChanged<int>? onPick;

  const _CardRing({
    super.key,
    required this.slots,
    required this.isWide,
    required this.onPick,
  });

  @override
  State<_CardRing> createState() => _CardRingState();
}

class _CardRingState extends State<_CardRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  double _radius = 120;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _spin.stop();
    _spin.value += details.delta.dx / _radius;
  }

  void _onPanEnd(DragEndDetails details) {
    final angularVelocity = details.velocity.pixelsPerSecond.dx / _radius;
    final sim = FrictionSimulation(0.06, _spin.value, angularVelocity);
    _spin.animateWith(sim);
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.slots.length;
    final maxDiameter = widget.isWide ? 560.0 : 340.0;
    final cardWidth = widget.isWide ? 62.0 : 40.0;
    final glassSize = widget.isWide ? 78.0 : 56.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = min(constraints.maxWidth, maxDiameter);
        _radius = diameter / 2 - cardWidth * 0.85;
        return GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _CentralGlass(size: glassSize),
                for (var i = 0; i < count; i++)
                  _buildSlot(i, count, widget.slots[i], cardWidth),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlot(int i, int count, PlayingCard? card, double cardWidth) {
    final angle = (i / count) * 2 * pi + _spin.value;
    return Transform.translate(
      offset: Offset(_radius * sin(angle), -_radius * cos(angle)),
      child: Transform.rotate(
        angle: angle,
        child: SizedBox(
          key: ValueKey('ringo-slot-$i'),
          width: cardWidth,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: card == null
                ? const _EmptySocket(key: ValueKey('empty'))
                : TapScale(
                    key: const ValueKey('card'),
                    onTap: widget.onPick == null
                        ? null
                        : () => widget.onPick!(i),
                    child: const CardBackWidget(),
                  ),
          ),
        ),
      ),
    );
  }
}

/// What a lifted card's slot looks like once it's gone: a faint outline of
/// where a card used to sit, so the ring visibly thins out over a round.
class _EmptySocket extends StatelessWidget {
  const _EmptySocket({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.68,
      child: LayoutBuilder(
        builder: (context, constraints) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              (constraints.maxWidth * 0.12).clamp(4.0, 16.0),
            ),
            border: Border.all(color: Colors.white24, width: 1),
          ),
        ),
      ),
    );
  }
}

/// The central glass every King fills — the ring's fixed point, and the
/// thing a 4th King, or a broken circle, finally empties.
class _CentralGlass extends StatelessWidget {
  final double size;

  const _CentralGlass({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kSurface,
        border: Border.all(color: kGold.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Icon(
        Icons.local_bar_rounded,
        color: kGold.withValues(alpha: 0.55),
        size: size * 0.46,
      ),
    );
  }
}

/// The lifted, flipped card together with its rule text. A climax moment —
/// the 4th King or a broken circle — gets a visibly bigger, gold-lit
/// treatment, the one time gold is allowed to take over the screen.
class _RevealPanel extends StatelessWidget {
  final PlayingCard card;
  final AnimationController controller;
  final RingoClimax? climax;
  final bool isWide;
  final VoidCallback onTap;

  const _RevealPanel({
    super.key,
    required this.card,
    required this.controller,
    required this.climax,
    required this.isWide,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isClimax = climax != null;
    final rule = isClimax ? ringoClimaxRule(climax!) : ringoRuleFor(card);

    return TapScale(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: isWide ? 300 : 220,
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
                    decoration: isClimax
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
                    fontFamily: isClimax ? kFontDisplay : null,
                    color: isClimax ? kGold : Colors.white,
                    fontSize: isClimax ? 28 : 19,
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

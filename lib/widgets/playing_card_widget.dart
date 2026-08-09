import 'dart:math';
import 'package:flutter/material.dart';
import '../models/playing_card.dart';

class CardFrontFace extends StatelessWidget {
  final PlayingCard card;

  const CardFrontFace({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.68,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: _CornerLabel(card: card),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.rotate(
                angle: pi,
                child: _CornerLabel(card: card),
              ),
            ),
            Center(
              child: Text(
                card.suitSymbol,
                style: TextStyle(fontSize: 96, color: card.displayColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerLabel extends StatelessWidget {
  final PlayingCard card;
  const _CornerLabel({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          card.rankLabel,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: card.displayColor, height: 1),
        ),
        Text(
          card.suitSymbol,
          style: TextStyle(fontSize: 20, color: card.displayColor, height: 1),
        ),
      ],
    );
  }
}

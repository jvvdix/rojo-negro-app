import 'package:flutter/material.dart';
import '../main.dart';

/// The face-down side of a Ringo card: a branded back, never a suit or rank,
/// so the player has to commit to lifting one before it's revealed.
class CardBackWidget extends StatelessWidget {
  const CardBackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.68,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kRed, kOxblood],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: kGold.withValues(alpha: 0.35), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(top: 10, left: 12, child: _CornerMark()),
              Positioned(bottom: 10, right: 12, child: Transform.rotate(angle: 3.14159, child: const _CornerMark())),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kGold.withValues(alpha: 0.5), width: 2.5),
                ),
                child: Icon(Icons.local_fire_department_rounded, color: kGold.withValues(alpha: 0.55), size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CornerMark extends StatelessWidget {
  const _CornerMark();

  @override
  Widget build(BuildContext context) {
    return Text(
      'R',
      style: TextStyle(
        fontFamily: kFontDisplay,
        fontSize: 18,
        color: kGold.withValues(alpha: 0.5),
        height: 1,
      ),
    );
  }
}

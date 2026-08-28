import 'package:flutter/material.dart';
import '../main.dart';

/// The face-down side of a Ringo card: a branded back, never a suit or rank,
/// so the player has to commit to lifting one before it's revealed. Every
/// inner proportion scales off the card's own rendered width, so it reads as
/// a rounded rectangle rather than a pill/oval at the ring's small sizes and
/// at the big reveal size alike.
class CardBackWidget extends StatelessWidget {
  const CardBackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.68,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final outerRadius = (w * 0.12).clamp(4.0, 24.0);
          final innerRadius = (w * 0.08).clamp(3.0, 16.0);
          final pad = (w * 0.1).clamp(3.0, 10.0);
          final iconSize = (w * 0.5).clamp(16.0, 68.0);
          final showCorners = w >= 60;

          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kRed, kOxblood],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(outerRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.all(pad),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: kGold.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(innerRadius),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (showCorners)
                    Positioned(
                      top: pad,
                      left: pad * 1.2,
                      child: _CornerMark(fontSize: (w * 0.16).clamp(9.0, 18.0)),
                    ),
                  if (showCorners)
                    Positioned(
                      bottom: pad,
                      right: pad * 1.2,
                      child: Transform.rotate(
                        angle: 3.14159,
                        child: _CornerMark(
                          fontSize: (w * 0.16).clamp(9.0, 18.0),
                        ),
                      ),
                    ),
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kGold.withValues(alpha: 0.5),
                        width: (iconSize * 0.04).clamp(1.5, 2.5),
                      ),
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: kGold.withValues(alpha: 0.55),
                      size: iconSize * 0.44,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CornerMark extends StatelessWidget {
  final double fontSize;

  const _CornerMark({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      'R',
      style: TextStyle(
        fontFamily: kFontDisplay,
        fontSize: fontSize,
        color: kGold.withValues(alpha: 0.5),
        height: 1,
      ),
    );
  }
}

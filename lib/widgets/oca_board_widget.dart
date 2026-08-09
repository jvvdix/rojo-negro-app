import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/oca_board.dart';
import '../models/oca_player.dart';

/// Real oca boards paint every space a bright, varied color regardless of
/// what's on it — the icon carries the meaning, the color carries the life.
/// Cycled by square number so neighboring tiles read as distinct.
const _tileColors = [
  Color(0xFFE0973D), // warm orange
  Color(0xFF4A90D9), // sky blue
  Color(0xFF5FA05A), // leaf green
  Color(0xFF9C5FA0), // soft purple
];

class OcaBoardWidget extends StatelessWidget {
  final List<OcaPlayer> players;
  final int currentPlayerIndex;

  const OcaBoardWidget({super.key, required this.players, required this.currentPlayerIndex});

  static const _framePadding = 6.0;

  @override
  Widget build(BuildContext context) {
    final positions = generateSpiralPositions();

    // The spiral only visits the outer rings of the grid; whatever cells it
    // never reaches form the open area a real oca board fills with artwork.
    final used = positions.map((p) => p.row * ocaBoardGridSize + p.col).toSet();
    var minCol = ocaBoardGridSize, maxCol = -1, minRow = ocaBoardGridSize, maxRow = -1;
    for (var r = 0; r < ocaBoardGridSize; r++) {
      for (var c = 0; c < ocaBoardGridSize; c++) {
        if (used.contains(r * ocaBoardGridSize + c)) continue;
        if (c < minCol) minCol = c;
        if (c > maxCol) maxCol = c;
        if (r < minRow) minRow = r;
        if (r > maxRow) maxRow = r;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = min(
          (constraints.maxWidth - _framePadding * 2) / ocaBoardGridSize,
          (constraints.maxHeight - _framePadding * 2) / ocaBoardGridSize,
        );
        final boardSide = cellSize * ocaBoardGridSize;

        // Group players by square so shared squares can render a small cluster.
        final bySquare = <int, List<OcaPlayer>>{};
        for (final p in players) {
          if (p.position > 0) bySquare.putIfAbsent(p.position, () => []).add(p);
        }

        return Center(
          child: Container(
            padding: const EdgeInsets.all(_framePadding),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: kGold.withValues(alpha: 0.28), width: 1.6),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: SizedBox(
              width: boardSide,
              height: boardSide,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _OcaTrackPainter(positions: positions, cellSize: cellSize)),
                  ),
                  if (maxCol >= minCol)
                    _centerpiece(
                      left: minCol * cellSize,
                      top: minRow * cellSize,
                      width: (maxCol - minCol + 1) * cellSize,
                      height: (maxRow - minRow + 1) * cellSize,
                    ),
                  for (var i = 0; i < ocaBoardSquareCount; i++)
                    _cell(ocaSquares[i], positions[i], cellSize),
                  for (final entry in bySquare.entries)
                    for (var j = 0; j < entry.value.length; j++)
                      _token(
                        entry.value[j],
                        positions[entry.value[j].position - 1],
                        cellSize,
                        clusterIndex: j,
                        clusterSize: entry.value.length,
                        isCurrent: players.indexOf(entry.value[j]) == currentPlayerIndex,
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// The open middle a real oca board fills with a big illustration. Sized
  /// to the actual unused cells left by the spiral, so it never overlaps a
  /// square drawn on top of it.
  Widget _centerpiece({required double left, required double top, required double width, required double height}) {
    final size = min(width, height);
    return Positioned(
      left: left + (width - size) / 2,
      top: top + (height - size) / 2,
      width: size,
      height: size,
      child: Container(
        margin: EdgeInsets.all(size * 0.06),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [kSurfaceRaised, kSurface]),
          border: Border.all(color: kGold.withValues(alpha: 0.35), width: size * 0.018),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: size * 0.08, offset: Offset(0, size * 0.03)),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.1,
              left: size * 0.12,
              child: Text('☀️', style: TextStyle(fontSize: size * 0.16)),
            ),
            Positioned(
              bottom: size * 0.12,
              right: size * 0.14,
              child: Text('🌿', style: TextStyle(fontSize: size * 0.15)),
            ),
            Text('🍷', style: TextStyle(fontSize: size * 0.42)),
          ],
        ),
      ),
    );
  }

  Widget _cell(OcaSquare square, GridPos pos, double cellSize) {
    final isGoal = square.type == OcaSquareType.goal;
    final isFinalDare = square.type == OcaSquareType.finalDare;
    final showEmoji = square.emoji.isNotEmpty;
    // Circular spaces sitting slightly inset from the cell grid so the track
    // painted underneath shows through the gaps, like beads on a string.
    final circleSize = cellSize * 0.82;

    return Positioned(
      left: pos.col * cellSize + (cellSize - circleSize) / 2,
      top: pos.row * cellSize + (cellSize - circleSize) / 2,
      width: circleSize,
      height: circleSize,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isGoal
              ? kGold
              : isFinalDare
                  ? kOxblood
                  : _tileColors[square.number % _tileColors.length],
          border: isGoal
              ? Border.all(color: Colors.white, width: circleSize * 0.05)
              : isFinalDare
                  ? Border.all(color: Colors.white, width: circleSize * 0.05)
                  : Border.all(color: Colors.white.withValues(alpha: 0.4), width: circleSize * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: circleSize * 0.12,
              offset: Offset(0, circleSize * 0.05),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: showEmoji
            // Force every icon to a solid white silhouette instead of its
            // native emoji colors: some platforms render color emoji with
            // washed-out/pale glyphs, and a flat white icon reads crisp on
            // every tile color regardless.
            ? ColorFiltered(
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                child: Text(square.emoji, style: TextStyle(fontSize: circleSize * 0.48)),
              )
            : Text(
                '${square.number}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: circleSize * 0.34,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: circleSize * 0.1)],
                ),
              ),
      ),
    );
  }

  Widget _token(
    OcaPlayer player,
    GridPos pos,
    double cellSize, {
    required int clusterIndex,
    required int clusterSize,
    required bool isCurrent,
  }) {
    final tokenSize = _tokenSize(clusterSize, cellSize);
    final offsets = _clusterOffsets(clusterSize, tokenSize);
    final offset = offsets[clusterIndex];

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutQuad,
      left: pos.col * cellSize + cellSize / 2 - tokenSize / 2 + offset.dx,
      top: pos.row * cellSize + cellSize / 2 - tokenSize / 2 + offset.dy,
      width: tokenSize,
      height: tokenSize,
      child: _AnimatedToken(player: player, isCurrent: isCurrent, size: tokenSize),
    );
  }

  /// Shrinks tokens as more players share a square so a crowded cell (well,
  /// jail, or the final-stretch squares) stays readable instead of smearing
  /// into one illegible blob.
  double _tokenSize(int clusterSize, double cellSize) {
    if (clusterSize <= 1) return cellSize * 0.56;
    if (clusterSize == 2) return cellSize * 0.48;
    if (clusterSize <= 4) return cellSize * 0.38;
    return cellSize * 0.30;
  }

  List<Offset> _clusterOffsets(int count, double tokenSize) {
    if (count <= 1) return [Offset.zero];
    final radius = tokenSize * 0.62;
    return List.generate(count, (i) {
      final angle = (2 * pi * i) / count - pi / 2;
      return Offset(cos(angle) * radius, sin(angle) * radius);
    });
  }
}

/// Paints the connecting track through every square's center, in board
/// order, so the spaces read as beads strung along one continuous path —
/// the visual signature of a real "juego de la oca" board.
class _OcaTrackPainter extends CustomPainter {
  final List<GridPos> positions;
  final double cellSize;

  _OcaTrackPainter({required this.positions, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;
    final paint = Paint()
      ..color = kGold.withValues(alpha: 0.24)
      ..strokeWidth = cellSize * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < positions.length; i++) {
      final center = Offset(
        positions[i].col * cellSize + cellSize / 2,
        positions[i].row * cellSize + cellSize / 2,
      );
      if (i == 0) {
        path.moveTo(center.dx, center.dy);
      } else {
        path.lineTo(center.dx, center.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OcaTrackPainter oldDelegate) => oldDelegate.cellSize != cellSize;
}

class _AnimatedToken extends StatefulWidget {
  final OcaPlayer player;
  final bool isCurrent;
  final double size;

  const _AnimatedToken({required this.player, required this.isCurrent, required this.size});

  @override
  State<_AnimatedToken> createState() => _AnimatedTokenState();
}

class _AnimatedTokenState extends State<_AnimatedToken> with SingleTickerProviderStateMixin {
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void didUpdateWidget(_AnimatedToken oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.player.position != widget.player.position) {
      _hop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _hop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hop,
      builder: (context, child) {
        final lift = sin(_hop.value * pi) * widget.size * 0.22;
        return Transform.translate(offset: Offset(0, -lift), child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.player.color,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: widget.isCurrent
              ? [BoxShadow(color: kRed.withValues(alpha: 0.7), blurRadius: widget.size * 0.5, spreadRadius: 1)]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          widget.player.initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: widget.size * 0.42,
          ),
        ),
      ),
    );
  }
}

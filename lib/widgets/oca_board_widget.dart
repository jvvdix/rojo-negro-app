import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/oca_board.dart';
import '../models/oca_player.dart';

class OcaBoardWidget extends StatelessWidget {
  final List<OcaPlayer> players;
  final int currentPlayerIndex;

  const OcaBoardWidget({super.key, required this.players, required this.currentPlayerIndex});

  @override
  Widget build(BuildContext context) {
    final positions = generateSpiralPositions();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = min(
          constraints.maxWidth / ocaBoardCols,
          constraints.maxHeight / ocaBoardRows,
        );
        final boardWidth = cellSize * ocaBoardCols;
        final boardHeight = cellSize * ocaBoardRows;

        // Group players by square so shared squares can render a small cluster.
        final bySquare = <int, List<OcaPlayer>>{};
        for (final p in players) {
          if (p.position > 0) bySquare.putIfAbsent(p.position, () => []).add(p);
        }

        return Center(
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: Stack(
              children: [
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
        );
      },
    );
  }

  Widget _cell(OcaSquare square, GridPos pos, double cellSize) {
    final isGoal = square.type == OcaSquareType.goal;
    final showEmoji = square.emoji.isNotEmpty;
    return Positioned(
      left: pos.col * cellSize,
      top: pos.row * cellSize,
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: EdgeInsets.all(cellSize * 0.04),
        child: Container(
          decoration: BoxDecoration(
            color: isGoal ? kGold.withValues(alpha: 0.18) : kSurface,
            borderRadius: BorderRadius.circular(cellSize * 0.16),
            border: isGoal ? Border.all(color: kGold, width: 1.4) : null,
          ),
          alignment: Alignment.center,
          child: showEmoji
              ? Text(square.emoji, style: TextStyle(fontSize: cellSize * 0.42))
              : Text(
                  '${square.number}',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: cellSize * 0.26,
                    fontWeight: FontWeight.w700,
                  ),
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
    final tokenSize = cellSize * 0.56;
    final offsets = _clusterOffsets(clusterSize, cellSize);
    final offset = offsets[clusterIndex];

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutQuad,
      left: pos.col * cellSize + cellSize / 2 - tokenSize / 2 + offset.dx,
      top: pos.row * cellSize + cellSize / 2 - tokenSize / 2 + offset.dy,
      width: tokenSize,
      height: tokenSize,
      child: _AnimatedToken(player: player, isCurrent: isCurrent, size: tokenSize),
    );
  }

  List<Offset> _clusterOffsets(int count, double cellSize) {
    if (count <= 1) return [Offset.zero];
    final radius = cellSize * 0.16;
    return List.generate(count, (i) {
      final angle = (2 * pi * i) / count;
      return Offset(cos(angle) * radius, sin(angle) * radius);
    });
  }
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

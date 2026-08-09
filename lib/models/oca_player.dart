import 'package:flutter/material.dart';

const ocaTokenColors = <Color>[
  Color(0xFF3FA79A), // teal
  Color(0xFF3E93B8), // azul cielo
  Color(0xFF4C7FD1), // denim
  Color(0xFF6C6FD8), // índigo
  Color(0xFF8B6FDB), // violeta
  Color(0xFFA96FCB), // orquídea
  Color(0xFFB96FA8), // malva
  Color(0xFF6E8F63), // salvia
];

class OcaPlayer {
  final String name;
  final Color color;

  /// 0 = aún no ha entrado al tablero. 1-63 = casilla actual.
  int position;

  /// Turnos pendientes por perder (posada/cárcel).
  int skippedTurnsLeft;

  OcaPlayer({
    required this.name,
    required this.color,
    this.position = 0,
    this.skippedTurnsLeft = 0,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  bool get hasWon => position == 63;
}

/// A real "juego de la oca" board is a square track that hugs the outer
/// edge and spirals inward, leaving a large open area in the middle for
/// artwork. The grid is bigger than the square count on purpose: only the
/// outer rings are ever visited, so [generateSpiralPositions] stops once it
/// has placed [ocaBoardSquareCount] squares, leaving the untouched interior
/// cells free for a decorative centerpiece.
const ocaBoardGridSize = 9;
const ocaBoardSquareCount = 63;

class GridPos {
  final int col;
  final int row;
  const GridPos(this.col, this.row);
}

/// Visitation order of a square inward spiral, stopping after [count]
/// cells. Index 0 is the outer starting corner; later indices hug the
/// edge of the grid and only reach inward once the outer rings are used up.
List<GridPos> generateSpiralPositions({int gridSize = ocaBoardGridSize, int count = ocaBoardSquareCount}) {
  final positions = <GridPos>[];
  var top = 0, bottom = gridSize - 1, left = 0, right = gridSize - 1;
  while (positions.length < count && top <= bottom && left <= right) {
    for (var c = left; c <= right && positions.length < count; c++) {
      positions.add(GridPos(c, top));
    }
    top++;
    for (var r = top; r <= bottom && positions.length < count; r++) {
      positions.add(GridPos(right, r));
    }
    right--;
    if (top <= bottom) {
      for (var c = right; c >= left && positions.length < count; c--) {
        positions.add(GridPos(c, bottom));
      }
      bottom--;
    }
    if (left <= right) {
      for (var r = bottom; r >= top && positions.length < count; r--) {
        positions.add(GridPos(left, r));
      }
      left++;
    }
  }
  return positions;
}

enum OcaSquareType { normal, drink, giveDrink, goose, bridge, inn, duel, labyrinth, jail, skull, goal, finalDare, tongueTwister }

class OcaSquare {
  final int number;
  final OcaSquareType type;
  final String emoji;
  final String description;
  final int? jumpTo;
  final bool oneWay;

  const OcaSquare({
    required this.number,
    required this.type,
    this.emoji = '',
    this.description = '',
    this.jumpTo,
    this.oneWay = false,
  });
}

const _geese = {5, 9, 14, 18, 23, 27, 32, 36, 41, 45, 50, 54, 59};
const _drinks = {3, 11, 16, 21, 29, 38, 44, 48, 56};

/// Interspersed between the other special squares: instead of drinking
/// yourself, you hand out 1 trago to whoever you want.
const _gives = {2, 8, 13, 17, 22, 26, 33, 37, 43, 47, 51, 55};

/// Interspersed between the other special squares: read the tongue-twister
/// out loud, stumble and you drink. Each one gets its own trabalenguas.
const _tongueTwisters = {
  4: 'Tres tristes tigres tragaban trigo en un trigal.',
  10: 'Pablito clavó un clavito, ¿qué clavito clavó Pablito?',
  20: 'Como poco coco como, poco coco compro.',
  30: 'El perro de San Roque no tiene rabo porque Ramón Ramírez se lo ha robado.',
  40: 'Si Sansón no sazona su salsa con sal, le sale sosa la salsa a Sansón.',
  49: 'El cielo está enladrillado, ¿quién lo desenladrillará? El desenladrillador que lo desenladrille, buen desenladrillador será.',
};

/// The 3 squares right before the goal: harder, spicier dares to raise the
/// tension on the home stretch. Visually flagged in the board widget too.
const _finalDares = {
  60: 'RECTA FINAL 🔥 Reparte 3 tragos como quieras: puedes dártelos todos a ti o repartirlos entre el grupo.',
  61: 'RECTA FINAL 🔥 El jugador de tu derecha te hace una pregunta comprometida. Respondes con la verdad o bebes 3 tragos.',
  62: 'RECTA FINAL 🔥 Última prueba: mantén el contacto visual con quien tengas enfrente 30 segundos sin reírte. Si fallas, bebes todo lo que quede en tu vaso.',
};

OcaSquare _buildSquare(int n) {
  if (n == 6) {
    return const OcaSquare(
      number: 6,
      type: OcaSquareType.bridge,
      emoji: '🌉',
      description: 'Puente: saltas a la 12. Bebes un trago.',
      jumpTo: 12,
      oneWay: true,
    );
  }
  if (n == 19) {
    return const OcaSquare(
      number: 19,
      type: OcaSquareType.inn,
      emoji: '🛏️',
      description: 'Posada: pierdes el próximo turno. Bebes por descansar.',
    );
  }
  if (n == 31) {
    return const OcaSquare(
      number: 31,
      type: OcaSquareType.duel,
      emoji: '🤜',
      description: 'Duelo: retas al jugador de tu derecha a piedra, papel o tijera. Quien pierda bebe 2 tragos.',
    );
  }
  if (n == 42) {
    return const OcaSquare(
      number: 42,
      type: OcaSquareType.labyrinth,
      emoji: '🌀',
      description: 'Laberinto: retrocedes a la 30. Bebes.',
      jumpTo: 30,
      oneWay: true,
    );
  }
  if (n == 52) {
    return const OcaSquare(
      number: 52,
      type: OcaSquareType.jail,
      emoji: '🔒',
      description: 'Cárcel: pierdes 2 turnos. Bebes cada turno perdido.',
    );
  }
  if (n == 58) {
    return const OcaSquare(
      number: 58,
      type: OcaSquareType.skull,
      emoji: '💀',
      description: 'Calavera: vuelves a la casilla 1. Bebes doble.',
      jumpTo: 1,
      oneWay: true,
    );
  }
  if (n == 63) {
    return const OcaSquare(
      number: 63,
      type: OcaSquareType.goal,
      emoji: '🏁',
      description: '¡Meta! Ganaste. Todos beben por ti.',
    );
  }
  if (_finalDares.containsKey(n)) {
    return OcaSquare(
      number: n,
      type: OcaSquareType.finalDare,
      emoji: '🔥',
      description: _finalDares[n]!,
    );
  }
  if (_geese.contains(n)) {
    return OcaSquare(
      number: n,
      type: OcaSquareType.goose,
      emoji: '🦢',
      description: 'OCA: tu amigo y tú bebéis porque os toca!',
    );
  }
  if (_gives.contains(n)) {
    return OcaSquare(
      number: n,
      type: OcaSquareType.giveDrink,
      emoji: '🍻',
      description: 'Reparte 1 trago a quien quieras.',
    );
  }
  if (_tongueTwisters.containsKey(n)) {
    return OcaSquare(
      number: n,
      type: OcaSquareType.tongueTwister,
      emoji: '👅',
      description: 'Lee el siguiente trabalenguas. Si te trabas, bebes: "${_tongueTwisters[n]}"',
    );
  }
  if (_drinks.contains(n)) {
    return OcaSquare(
      number: n,
      type: OcaSquareType.drink,
      emoji: '🥃',
      description: 'Bebes un trago.',
    );
  }
  return OcaSquare(number: n, type: OcaSquareType.normal);
}

final List<OcaSquare> ocaSquares = List.generate(ocaBoardSquareCount, (i) => _buildSquare(i + 1));

OcaSquare ocaSquareAt(int number) => ocaSquares[number - 1];

/// Resolves where a player lands after moving [steps] from [start].
///
/// The goal square acts as the only wall on the board: a move that would
/// land past it bounces back by the overshoot instead of stopping there.
/// There is no wall at square 1, so a landing below it (only reachable with
/// a [steps] far larger than any die can produce) clamps to square 1 rather
/// than reflecting again.
int reflectOcaPosition(int start, int steps, {int boardSize = ocaBoardSquareCount}) {
  final raw = start + steps;
  if (raw <= boardSize) return raw;
  final overshoot = raw - boardSize;
  final bounced = boardSize - overshoot;
  return bounced < 1 ? 1 : bounced;
}

import 'playing_card.dart';

/// The rule tied to one rank in Ringo (Ring of Fire / Kings). [headline] is
/// the shouted rule name, [description] the sentence explaining it.
class RingoRule {
  final String headline;
  final String description;

  const RingoRule({required this.headline, required this.description});
}

const _rulesByRank = <int, RingoRule>{
  1: RingoRule(
    headline: 'CASCADA',
    description:
        'Todos empiezan a beber a la vez que quien sacó la carta. Nadie puede parar hasta que la persona anterior lo haga.',
  ),
  2: RingoRule(headline: 'TÚ ELIGES', description: 'Elige quién bebe.'),
  3: RingoRule(headline: 'YO', description: 'Bebe quien ha sacado la carta.'),
  4: RingoRule(headline: 'CHICAS', description: 'Beben todas las chicas.'),
  5: RingoRule(
    headline: 'MAESTRO DEL PULGAR',
    description: 'Pon el dedo sobre la mesa. El último en imitarte, bebe.',
  ),
  6: RingoRule(headline: 'CHICOS', description: 'Beben todos los chicos.'),
  7: RingoRule(
    headline: 'CIELO',
    description: 'Todos apuntan al cielo. El último en hacerlo, bebe.',
  ),
  8: RingoRule(
    headline: 'COMPAÑERO',
    description:
        'Elige a alguien: beberá siempre que tú bebas el resto de la partida.',
  ),
  9: RingoRule(
    headline: 'RIMA',
    description:
        'Di una palabra. Por turnos, el resto debe rimar con ella; quien falle, bebe.',
  ),
  10: RingoRule(
    headline: 'CATEGORÍAS',
    description:
        'Elige un tema. Por turnos hay que nombrar algo de esa categoría; quien repita o tarde, bebe.',
  ),
  11: RingoRule(
    headline: 'REGLA NUEVA',
    description:
        'Inventa una norma que todos deben cumplir el resto de la partida.',
  ),
  12: RingoRule(
    headline: 'PREGUNTAS',
    description: 'No puedes responder a ninguna pregunta que te hagan.',
  ),
  13: RingoRule(
    headline: 'VASO CENTRAL',
    description: 'Vierte un poco de tu bebida en el vaso central.',
  ),
};

/// A "drink the whole central glass" climax, and what triggered it.
enum RingoClimax { king, circleBroken }

const _climaxRules = <RingoClimax, RingoRule>{
  RingoClimax.king: RingoRule(
    headline: '¡EL CUARTO REY!',
    description: 'Bébete todo el contenido del vaso central.',
  ),
  RingoClimax.circleBroken: RingoRule(
    headline: '¡CÍRCULO ROTO!',
    description:
        'Has roto el círculo de cartas. Bébete todo el contenido del vaso central.',
  ),
};

/// The normal rule for [card]'s rank.
RingoRule ringoRuleFor(PlayingCard card) => _rulesByRank[card.rank]!;

/// The rule for a central-glass climax moment, regardless of which card
/// triggered it.
RingoRule ringoClimaxRule(RingoClimax climax) => _climaxRules[climax]!;

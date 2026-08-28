import 'dart:math';
import 'playing_card.dart';

/// The result of lifting a card out of the circle.
class RingoPick {
  final PlayingCard card;

  /// True when this pick left two already-empty slots adjacent to each
  /// other — the moment the circle of cards visually breaks.
  final bool brokeCircle;

  const RingoPick({required this.card, required this.brokeCircle});
}

/// The 52 cards laid out once around the table in a fixed circle. Picking a
/// card leaves its slot empty rather than closing the gap, exactly like the
/// real game: the circle visibly thins out over a round instead of shrinking
/// back down to a smaller wheel.
class RingoCircle {
  final List<PlayingCard?> slots;

  RingoCircle._(this.slots);

  factory RingoCircle.shuffled({Random? random}) {
    final cards = <PlayingCard>[
      for (final suit in Suit.values)
        for (var rank = 1; rank <= 13; rank++)
          PlayingCard(suit: suit, rank: rank),
    ];
    cards.shuffle(random ?? Random());
    return RingoCircle._(List<PlayingCard?>.of(cards));
  }

  /// Rebuilds a circle from its exact slots (cards and gaps alike), in
  /// original table order — used to resume a session instead of reshuffling.
  factory RingoCircle.fromSlots(List<PlayingCard?> slots) =>
      RingoCircle._(List.of(slots));

  int get total => slots.length;

  int get remaining => slots.where((c) => c != null).length;

  bool get isEmpty => remaining == 0;

  RingoPick drawAt(int index) {
    final card = slots[index]!;
    final n = slots.length;
    final leftEmpty = slots[(index - 1 + n) % n] == null;
    final rightEmpty = slots[(index + 1) % n] == null;
    slots[index] = null;
    return RingoPick(card: card, brokeCircle: leftEmpty || rightEmpty);
  }

  List<Map<String, dynamic>?> toJson() =>
      slots.map((c) => c?.toJson()).toList();

  static List<PlayingCard?> slotsFromJson(List<dynamic> json) => json
      .map(
        (e) =>
            e == null ? null : PlayingCard.fromJson(e as Map<String, dynamic>),
      )
      .toList();
}

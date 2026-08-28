import 'dart:math';
import 'package:flutter/material.dart';

enum Suit { hearts, diamonds, clubs, spades }

enum CardColor { red, black }

class PlayingCard {
  final Suit suit;
  final int rank; // 1 = A, 2..10, 11 = J, 12 = Q, 13 = K

  const PlayingCard({required this.suit, required this.rank});

  CardColor get color =>
      suit == Suit.hearts || suit == Suit.diamonds ? CardColor.red : CardColor.black;

  Color get displayColor =>
      color == CardColor.red ? const Color(0xFFE0293B) : const Color(0xFF1A1A1A);

  String get suitSymbol {
    switch (suit) {
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.spades:
        return '♠';
    }
  }

  String get rankLabel {
    switch (rank) {
      case 1:
        return 'A';
      case 11:
        return 'J';
      case 12:
        return 'Q';
      case 13:
        return 'K';
      default:
        return '$rank';
    }
  }

  Map<String, dynamic> toJson() => {'suit': suit.index, 'rank': rank};

  static PlayingCard fromJson(Map<String, dynamic> json) =>
      PlayingCard(suit: Suit.values[json['suit'] as int], rank: json['rank'] as int);
}

class Deck {
  final List<PlayingCard> _cards;

  Deck._(this._cards);

  factory Deck.shuffled({Random? random}) {
    final cards = <PlayingCard>[
      for (final suit in Suit.values)
        for (var rank = 1; rank <= 13; rank++) PlayingCard(suit: suit, rank: rank),
    ];
    cards.shuffle(random ?? Random());
    return Deck._(cards);
  }

  /// Rebuilds a deck from its exact remaining cards, in draw order, without
  /// reshuffling — used to resume a session instead of starting over.
  factory Deck.fromCards(List<PlayingCard> cards) => Deck._(List.of(cards));

  int get remaining => _cards.length;

  bool get isEmpty => _cards.isEmpty;

  PlayingCard draw() => _cards.removeLast();

  /// The next [n] cards that would be drawn, without removing them — used to
  /// render a face-down spread the player can choose from freely instead of
  /// drawing strictly in order.
  List<PlayingCard> peek(int n) => _cards.reversed.take(n).toList();

  /// Draws a specific card out of the deck regardless of its position, since
  /// the player picks which face-down card to flip rather than always the
  /// top one. Each suit/rank combination is unique within a single deck.
  PlayingCard drawCard(PlayingCard card) {
    final index = _cards.indexWhere((c) => c.suit == card.suit && c.rank == card.rank);
    return _cards.removeAt(index);
  }

  List<Map<String, dynamic>> toJson() => _cards.map((c) => c.toJson()).toList();
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rojo_negro_app/models/playing_card.dart';
import 'package:rojo_negro_app/screens/ringo_screen.dart';

void main() {
  testWidgets('Ringo levanta la carta elegida, muestra su regla y cuenta los reyes', (tester) async {
    // Deck.peek() reads from the end of the list, so the last card here is
    // the first one drawn from the fan (leftmost slot).
    const cards = [
      PlayingCard(suit: Suit.clubs, rank: 2),
      PlayingCard(suit: Suit.clubs, rank: 3),
      PlayingCard(suit: Suit.clubs, rank: 4),
      PlayingCard(suit: Suit.clubs, rank: 5),
      PlayingCard(suit: Suit.clubs, rank: 6),
      PlayingCard(suit: Suit.clubs, rank: 7),
      PlayingCard(suit: Suit.spades, rank: 13),
    ];

    await tester.pumpWidget(const MaterialApp(
      home: RingoScreen(restore: RingoRestore(remainingCards: cards, kingsDrawn: 3)),
    ));
    await tester.pumpAndSettle();

    expect(find.text('MAZO: 7'), findsOneWidget);
    expect(find.byKey(const ValueKey(PlayingCard(suit: Suit.spades, rank: 13))), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey(PlayingCard(suit: Suit.spades, rank: 13))));
    await tester.pumpAndSettle();

    // The 4th King since the central glass was last emptied gets the climax rule.
    expect(find.text('¡EL CUARTO REY!'), findsOneWidget);
    expect(find.text('Bébete todo el contenido del vaso central.'), findsOneWidget);

    await tester.tap(find.text('¡EL CUARTO REY!'));
    await tester.pumpAndSettle();

    // The counter resets after the climax card is dismissed and the fan comes back.
    expect(find.text('MAZO: 6'), findsOneWidget);
    expect(find.text('¡EL CUARTO REY!'), findsNothing);
  });
}

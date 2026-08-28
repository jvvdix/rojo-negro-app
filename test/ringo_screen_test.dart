import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rojo_negro_app/models/playing_card.dart';
import 'package:rojo_negro_app/screens/ringo_screen.dart';

void main() {
  testWidgets(
    'Ringo levanta la carta elegida, muestra su regla y cuenta los reyes',
    (tester) async {
      const slots = <PlayingCard?>[
        PlayingCard(suit: Suit.spades, rank: 13),
        PlayingCard(suit: Suit.clubs, rank: 2),
        PlayingCard(suit: Suit.clubs, rank: 3),
        PlayingCard(suit: Suit.clubs, rank: 4),
        null,
        PlayingCard(suit: Suit.clubs, rank: 5),
        PlayingCard(suit: Suit.clubs, rank: 6),
        PlayingCard(suit: Suit.clubs, rank: 7),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: RingoScreen(
            restore: RingoRestore(
              slots: slots,
              kingsDrawn: 3,
              circleBroken: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('MAZO: 7'), findsOneWidget);

      // Slot 0 (the King) sits next to slot 7, which is still full — picking it
      // shouldn't break the circle yet, but it is the 4th King.
      await tester.tap(find.byKey(const ValueKey('ringo-slot-0')));
      await tester.pumpAndSettle();

      expect(find.text('¡EL CUARTO REY!'), findsOneWidget);
      expect(
        find.text('Bébete todo el contenido del vaso central.'),
        findsOneWidget,
      );

      await tester.tap(find.text('¡EL CUARTO REY!'));
      await tester.pumpAndSettle();

      // The counter resets after the climax card is dismissed and the ring comes back.
      expect(find.text('MAZO: 6'), findsOneWidget);
      expect(find.text('¡EL CUARTO REY!'), findsNothing);
    },
  );

  testWidgets('Ringo declara el círculo roto al dejar dos huecos contiguos', (
    tester,
  ) async {
    const slots = <PlayingCard?>[
      PlayingCard(suit: Suit.clubs, rank: 2),
      null,
      PlayingCard(suit: Suit.clubs, rank: 3),
      PlayingCard(suit: Suit.clubs, rank: 4),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: RingoScreen(
          restore: RingoRestore(
            slots: slots,
            kingsDrawn: 0,
            circleBroken: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Slot 0 is adjacent to the empty slot 1, so lifting it breaks the circle.
    await tester.tap(find.byKey(const ValueKey('ringo-slot-0')));
    await tester.pumpAndSettle();

    expect(find.text('¡CÍRCULO ROTO!'), findsOneWidget);
  });
}

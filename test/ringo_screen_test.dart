import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rojo_negro_app/main.dart';
import 'package:rojo_negro_app/models/playing_card.dart';
import 'package:rojo_negro_app/screens/ringo_screen.dart';

/// Counts the lit ("gold") King-tracker dots in the status bar.
int _litKingDots(WidgetTester tester) {
  return tester
      .widgetList<Container>(find.byType(Container))
      .where(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == kGold,
      )
      .length;
}

void main() {
  testWidgets(
    'Ringo levanta la carta elegida, muestra su regla y cuenta los reyes',
    (tester) async {
      // A phone-sized viewport: the desktop-only bigger sizing is covered by
      // its own layout, not by this interaction test.
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
            kingsDrawn: 2,
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
    expect(_litKingDots(tester), 2);

    await tester.tap(find.text('¡CÍRCULO ROTO!'));
    await tester.pumpAndSettle();

    // Breaking the circle doesn't restart the game: the 2 cards still left
    // in play (not a fresh deck) get reshuffled into a new, gap-free circle.
    expect(find.text('MAZO: 2'), findsOneWidget);
    // And it's a separate reason to empty the glass — it doesn't touch the
    // Kings tally the way the 4th King itself does.
    expect(_litKingDots(tester), 2);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rojo_negro_app/models/oca_board.dart';

void main() {
  group('reflectOcaPosition', () {
    test('lands directly on the goal with an exact roll', () {
      expect(reflectOcaPosition(60, 3), 63);
    });

    test('does not move past the goal on exact overshoot', () {
      expect(reflectOcaPosition(61, 2), 63);
    });

    test('bounces back by the overshoot amount (prompt example)', () {
      // 2 squares remaining, rolls a 4: reaches the goal, then bounces back
      // by the 2 extra steps, landing 2 squares short of it.
      expect(reflectOcaPosition(61, 4), 61);
    });

    test('bounce amount depends on remaining distance, not just the roll', () {
      // 3 squares remaining, rolls a 5: 2 steps overshoot the goal.
      expect(reflectOcaPosition(60, 5), 61);
    });

    test('never lands beyond the final board square', () {
      for (var start = 58; start <= 62; start++) {
        for (var steps = 1; steps <= 6; steps++) {
          final landing = reflectOcaPosition(start, steps);
          expect(landing, lessThanOrEqualTo(ocaBoardSquareCount));
          expect(landing, greaterThanOrEqualTo(1));
        }
      }
    });

    test('clamps to square 1 for a hypothetical overshoot bigger than the board', () {
      expect(reflectOcaPosition(60, 100), 1);
    });
  });
}
